# encoding: ascii-8bit
# typed: false
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
    end
  end
end
