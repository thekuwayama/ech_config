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
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0d 00 51 00 00 20 00     1e 00 00 00 00 00 00 00
        00 00 00 00 00 00 00 00     00 00 00 00 00 00 00 00
        00 00 00 00 00 00 00 00     04 00 01 00 01 00 09 6c
        6f 63 61 6c 68 6f 73 74     00 1b fe 0d 00 17 00 00
        00 00 68 00 00 00 00 00     04 30 59 30 13 04 03 00
        04 01 02 03 04
      BIN
    end

    let(:tbs_octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0d 00 4d 00 00 20 00     1e 00 00 00 00 00 00 00
        00 00 00 00 00 00 00 00     00 00 00 00 00 00 00 00
        00 00 00 00 00 00 00 00     04 00 01 00 01 00 09 6c
        6f 63 61 6c 68 6f 73 74     00 17 fe 0d 00 13 00 00
        00 00 68 00 00 00 00 00     04 30 59 30 13 04 03 00
        00
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
      expect(ech_auth.signature).to eq "\x01\x02\x03\x04"
      expect(ech_config.encode).to eq octet
    end

    it 'should be signed' do
      expect(ech_config.to_be_signed)
        .to eq ECHConfig::ECHConfigContents::Extensions::ECHAuth::CONTEXT_LABEL + tbs_octet
      expect(tbs_octet.length).to eq octet.length - ech_auth.signature.length
    end
  end
end
