# encoding: ascii-8bit
# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe ECHConfig do
  context 'valid echconfig octet' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0d 00 36 00 00 20 00     1e 00 00 00 00 00 00 00
        00 00 00 00 00 00 00 00     00 00 00 00 00 00 00 00
        00 00 00 00 00 00 00 00     04 00 01 00 01 00 09 6c
        6f 63 61 6c 68 6f 73 74     00 00
      BIN
    end

    let(:ech_configs) do
      ECHConfig.decode_vectors(octet)
    end

    it 'should decode' do
      expect(ech_configs.length).to eq 1
      expect(ech_configs.first.version).to eq "\xfe\x0d"

      key_config = ech_configs.first.echconfig_contents.key_config
      expect(key_config.config_id).to eq 0
      expect(key_config.kem_id.uint16).to eq 0x0020
      expect(key_config.public_key.opaque).to eq "\x00" * 30
      expect(key_config.cipher_suites.length).to eq 1
      expect(key_config.cipher_suites.first.kdf_id.uint16).to eq 0x0001
      expect(key_config.cipher_suites.first.aead_id.uint16).to eq 0x0001

      extensions = ech_configs.first.echconfig_contents.extensions
      expect(extensions).to be_empty
    end

    it 'should NOT be signed' do
      expect { ech_configs.first.to_be_signed }.to raise_error ECHConfig::Error
    end
  end

  context 'echconfig, which has ech_auth' do
    # ech-auth-interop test vector material, in draft-02 layout
    # https://github.com/grittygrease/ech-auth-interop/blob/main/test-vectors/interop.json
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0d 00 b9 01 00 20 00     20 1f c3 4f 30 da e9 73
        3d e8 1e 17 3e c5 9f f1     0f 1e ee a4 53 04 8f 1e
        30 aa 0b 45 25 88 56 a9     21 00 04 00 01 00 01 00
        0b 65 78 61 6d 70 6c 65     2e 63 6f 6d 00 7f fe 0d
        00 7b 00 00 00 00 69 84     d7 d6 00 00 2c 30 2a 30
        05 06 03 2b 65 70 03 21     00 aa e6 a4 8a 7e eb 96
        c6 da 22 bb 84 b9 52 85     3e d7 82 50 3f aa f8 ac
        f6 b5 27 ee cd c3 c7 36     3f 08 07 00 40 6d 86 cf
        1f 46 07 0a 53 70 e2 69     94 a5 bc 30 58 b2 0d 09
        33 ac 70 97 f1 e6 6c 92     46 04 d5 40 38 a2 20 25
        eb 52 21 5e 54 bf 3f ce     8e f9 7a 7d 4f d2 a1 4f
        56 f8 db 51 03 49 e4 c3     2a b9 d4 20 0f
      BIN
    end

    let(:tbs_octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0d 00 79 01 00 20 00     20 1f c3 4f 30 da e9 73
        3d e8 1e 17 3e c5 9f f1     0f 1e ee a4 53 04 8f 1e
        30 aa 0b 45 25 88 56 a9     21 00 04 00 01 00 01 00
        0b 65 78 61 6d 70 6c 65     2e 63 6f 6d 00 3f fe 0d
        00 3b 00 00 00 00 69 84     d7 d6 00 00 2c 30 2a 30
        05 06 03 2b 65 70 03 21     00 aa e6 a4 8a 7e eb 96
        c6 da 22 bb 84 b9 52 85     3e d7 82 50 3f aa f8 ac
        f6 b5 27 ee cd c3 c7 36     3f 08 07 00 00
      BIN
    end

    let(:ech_config) do
      ECHConfig.decode_vectors(octet).first
    end

    let(:ech_auth) do
      ech_config
        .echconfig_contents
        .extensions[ECHConfig::ECHConfigContents::Extensions::ECHAuth::TYPE]
    end

    it 'should decode' do
      expect(ech_auth.not_after).to eq 0x6984d7d6
      expect(ech_auth.algorithm).to eq 0x0807
      expect(ech_config.encode).to eq octet
    end

    it 'should be signed' do
      expect(ech_config.to_be_signed)
        .to eq ECHConfig::ECHConfigContents::Extensions::ECHAuth::CONTEXT_LABEL + tbs_octet
      expect(tbs_octet.length).to eq octet.length - ech_auth.signature.length
    end
  end

  context 'echconfig, whose ech_auth is signed with an ed25519 key' do
    let(:key) do
      OpenSSL::PKey.generate_key('ED25519')
    end

    let(:key_config) do
      hkc = ECHConfig::ECHConfigContents::HpkeKeyConfig
      hkc.new(
        0,
        hkc::HpkeKemId.new(0x0020),
        hkc::HpkePublicKey.new("\x00" * 32),
        [
          hkc::HpkeSymmetricCipherSuite.new(
            hkc::HpkeSymmetricCipherSuite::HpkeKdfId.new(0x0001),
            hkc::HpkeSymmetricCipherSuite::HpkeAeadId.new(0x0001)
          )
        ]
      )
    end

    def echconfig(key, signature)
      ech_auth = ECHConfig::ECHConfigContents::Extensions::ECHAuth.new(
        0x6984d7d6, 0, key.public_to_der, 0x0807, signature
      )
      ECHConfig.new(
        "\xfe\x0d",
        ECHConfig::ECHConfigContents.new(
          key_config,
          0,
          'localhost',
          ECHConfig::ECHConfigContents::Extensions.new([ech_auth])
        )
      )
    end

    it 'should verify' do
      signature = key.sign(nil, echconfig(key, '').to_be_signed)
      signed = ECHConfig.decode_vectors(echconfig(key, signature).encode).first

      ech_auth = signed
                 .echconfig_contents
                 .extensions[ECHConfig::ECHConfigContents::Extensions::ECHAuth::TYPE]
      expect(ech_auth.signature).to eq signature
      expect(signed.to_be_signed).to eq echconfig(key, '').to_be_signed
      expect(
        OpenSSL::PKey.read(ech_auth.spki)
                     .verify(nil, ech_auth.signature, signed.to_be_signed)
      ).to be true
    end
  end
end
