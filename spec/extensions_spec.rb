# encoding: ascii-8bit
# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe ECHConfig::ECHConfigContents::Extensions do
  let(:extensions) do
    ECHConfig::ECHConfigContents::Extensions
  end

  let(:ech_auth_info) do
    ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo
  end

  context 'ech_authinfo, which has 2 trusted_keys' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0e 00 42 00 40 01 01     01 01 01 01 01 01 01 01
        01 01 01 01 01 01 01 01     01 01 01 01 01 01 01 01
        01 01 01 01 01 01 02 02     02 02 02 02 02 02 02 02
        02 02 02 02 02 02 02 02     02 02 02 02 02 02 02 02
        02 02 02 02 02 02
      BIN
    end

    it 'should decode' do
      exs = extensions.decode(octet)
      expect(exs.length).to eq 1

      ex = exs[ech_auth_info::TYPE]
      expect(ex).to be_a ech_auth_info
      expect(ex.trusted_keys).to eq ["\x01" * 32, "\x02" * 32]
      expect(ex.mandatory?).to be true
      expect(exs.any_mandatory?).to be true
    end

    it 'should encode' do
      expect(extensions.decode(octet).encode).to eq octet
      expect(
        extensions.new([ech_auth_info.new(["\x01" * 32, "\x02" * 32])]).encode
      ).to eq octet
    end
  end

  context 'ech_authinfo, which has no trusted_keys' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0e 00 02 00 00
      BIN
    end

    it 'should NOT decode' do
      expect { extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
      expect { ech_auth_info.decode(octet.slice(4..) || '') }
        .to raise_error ECHConfig::DecodeError
    end

    it 'should NOT be constructed' do
      expect { ech_auth_info.new([]) }.to raise_error ArgumentError
    end
  end

  context 'ech_authinfo, which has trusted_keys not a multiple of 32' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0e 00 23 00 21 01 01     01 01 01 01 01 01 01 01
        01 01 01 01 01 01 01 01     01 01 01 01 01 01 01 01
        01 01 01 01 01 01 01
      BIN
    end

    it 'should NOT decode' do
      expect { extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
      expect { ech_auth_info.decode(octet.slice(4..) || '') }
        .to raise_error ECHConfig::DecodeError
    end
  end

  context 'ech_authinfo, whose trusted_keys length prefix disagrees with data' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0e 00 23 00 20 01 01     01 01 01 01 01 01 01 01
        01 01 01 01 01 01 01 01     01 01 01 01 01 01 01 01
        01 01 01 01 01 01 01
      BIN
    end

    it 'should NOT decode' do
      expect { extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
      expect { ech_auth_info.decode(octet.slice(4..) || '') }
        .to raise_error ECHConfig::DecodeError
    end
  end

  context 'unknown extension' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        00 01 00 02 aa bb
      BIN
    end

    it 'should decode' do
      exs = extensions.decode(octet)
      expect(exs.length).to eq 1

      ex = exs[0x0001]
      expect(ex).to be_a ECHConfig::ECHConfigContents::Extensions::UnknownExtension
      expect(ex.data).to eq "\xaa\xbb"
      expect(exs.any_mandatory?).to be false
      expect(exs.encode).to eq octet
    end
  end
end
