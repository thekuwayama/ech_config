# encoding: ascii-8bit
# typed: false
# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe ECHConfig::ECHConfigContents::HpkeKeyConfig do
  context 'valid hpke_key_config octet' do
    let(:octet) do
      "\xFF\x00\x20\x00\x20\x00\x00\x00" \
      "\x00\x00\x00\x00\x00\x00\x00\x00" \
      "\x00\x00\x00\x00\x00\x00\x00\x00" \
      "\x00\x00\x00\x00\x00\x00\x00\x00" \
      "\x00\x00\x00\x00\x00\x00\x08\x00" \
      "\x01\00\x01\x00\x01\x00\x03"
    end

    let(:hpke_key_config) do
      ECHConfig::ECHConfigContents::HpkeKeyConfig.decode(octet).first
    end

    it 'should decode' do
      expect(hpke_key_config.config_id).to eq 255
      expect(hpke_key_config.kem_id.uint16).to eq 32
      expect(hpke_key_config.public_key.opaque).to eq "\x00" * 32
      expect(hpke_key_config.cipher_suites[0].kdf_id.uint16).to eq 1
      expect(hpke_key_config.cipher_suites[0].aead_id.uint16).to eq 1
      expect(hpke_key_config.cipher_suites[1].kdf_id.uint16).to eq 1
      expect(hpke_key_config.cipher_suites[1].aead_id.uint16).to eq 3
    end
  end
end
