# encoding: ascii-8bit
# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe ECHConfig::ECHConfigContents::Extensions do
  # ech-auth-interop test vector material, in draft-02 layout
  # https://github.com/grittygrease/ech-auth-interop/blob/main/test-vectors/interop.json
  let(:spki) do
    <<-BIN.split.map(&:hex).map(&:chr).join
      30 2a 30 05 06 03 2b 65     70 03 21 00 aa e6 a4 8a
      7e eb 96 c6 da 22 bb 84     b9 52 85 3e d7 82 50 3f
      aa f8 ac f6 b5 27 ee cd     c3 c7 36 3f
    BIN
  end

  let(:signature) do
    <<-BIN.split.map(&:hex).map(&:chr).join
      6d 86 cf 1f 46 07 0a 53     70 e2 69 94 a5 bc 30 58
      b2 0d 09 33 ac 70 97 f1     e6 6c 92 46 04 d5 40 38
      a2 20 25 eb 52 21 5e 54     bf 3f ce 8e f9 7a 7d 4f
      d2 a1 4f 56 f8 db 51 03     49 e4 c3 2a b9 d4 20 0f
    BIN
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
      exs = ECHConfig::ECHConfigContents::Extensions.decode(octet)
      expect(exs.length).to eq 1

      ex = exs[ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo::TYPE]
      expect(ex).to be_a ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo
      expect(ex.trusted_keys).to eq ["\x01" * 32, "\x02" * 32]
      expect(ex.mandatory?).to be true
      expect(exs.any_unsupported_mandatory?).to be false
    end

    it 'should encode' do
      expect(ECHConfig::ECHConfigContents::Extensions.decode(octet).encode).to eq octet
      expect(
        ECHConfig::ECHConfigContents::Extensions.new(
          [ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo.new(["\x01" * 32, "\x02" * 32])]
        ).encode
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
      expect { ECHConfig::ECHConfigContents::Extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
      expect { ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo.decode(octet.slice(4..) || '') }
        .to raise_error ECHConfig::DecodeError
    end

    it 'should NOT be constructed' do
      expect { ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo.new([]) }.to raise_error ArgumentError
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
      expect { ECHConfig::ECHConfigContents::Extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
      expect { ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo.decode(octet.slice(4..) || '') }
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
      expect { ECHConfig::ECHConfigContents::Extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
      expect { ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo.decode(octet.slice(4..) || '') }
        .to raise_error ECHConfig::DecodeError
    end
  end

  context 'ech_auth' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0d 00 7b 00 00 00 00     69 84 d7 d6 00 00 2c 30
        2a 30 05 06 03 2b 65 70     03 21 00 aa e6 a4 8a 7e
        eb 96 c6 da 22 bb 84 b9     52 85 3e d7 82 50 3f aa
        f8 ac f6 b5 27 ee cd c3     c7 36 3f 08 07 00 40 6d
        86 cf 1f 46 07 0a 53 70     e2 69 94 a5 bc 30 58 b2
        0d 09 33 ac 70 97 f1 e6     6c 92 46 04 d5 40 38 a2
        20 25 eb 52 21 5e 54 bf     3f ce 8e f9 7a 7d 4f d2
        a1 4f 56 f8 db 51 03 49     e4 c3 2a b9 d4 20 0f
      BIN
    end

    it 'should decode' do
      exs = ECHConfig::ECHConfigContents::Extensions.decode(octet)
      expect(exs.length).to eq 1

      ex = exs[ECHConfig::ECHConfigContents::Extensions::ECHAuth::TYPE]
      expect(ex).to be_a ECHConfig::ECHConfigContents::Extensions::ECHAuth
      expect(ex.not_after).to eq 0x6984d7d6
      expect(ex.disable?).to be false
      expect(ex.spki).to eq spki
      expect(ex.algorithm).to eq 0x0807
      expect(ex.signature).to eq signature
      expect(ex.mandatory?).to be true
      expect(exs.any_unsupported_mandatory?).to be false
    end

    it 'should encode' do
      expect(ECHConfig::ECHConfigContents::Extensions.decode(octet).encode).to eq octet
      expect(
        ECHConfig::ECHConfigContents::Extensions.new(
          [ECHConfig::ECHConfigContents::Extensions::ECHAuth.new(0x6984d7d6, 0, spki, 0x0807, signature)]
        ).encode
      ).to eq octet
    end

    it 'should be disabled' do
      expect(
        ECHConfig::ECHConfigContents::Extensions::ECHAuth
          .new(0x6984d7d6, 1, spki, 0x0807, signature).disable?
      ).to be true
    end
  end

  context 'ech_auth, whose disable is neither 0 nor 1' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0d 00 7b 00 00 00 00     69 84 d7 d6 02 00 2c 30
        2a 30 05 06 03 2b 65 70     03 21 00 aa e6 a4 8a 7e
        eb 96 c6 da 22 bb 84 b9     52 85 3e d7 82 50 3f aa
        f8 ac f6 b5 27 ee cd c3     c7 36 3f 08 07 00 40 6d
        86 cf 1f 46 07 0a 53 70     e2 69 94 a5 bc 30 58 b2
        0d 09 33 ac 70 97 f1 e6     6c 92 46 04 d5 40 38 a2
        20 25 eb 52 21 5e 54 bf     3f ce 8e f9 7a 7d 4f d2
        a1 4f 56 f8 db 51 03 49     e4 c3 2a b9 d4 20 0f
      BIN
    end

    it 'should NOT decode' do
      expect { ECHConfig::ECHConfigContents::Extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
      expect { ECHConfig::ECHConfigContents::Extensions::ECHAuth.decode(octet.slice(4..) || '') }
        .to raise_error ECHConfig::DecodeError
    end

    it 'should NOT be constructed' do
      expect { ECHConfig::ECHConfigContents::Extensions::ECHAuth.new(0x6984d7d6, 2, spki, 0x0807, signature) }
        .to raise_error ArgumentError
    end
  end

  context 'ech_auth, which has no spki' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0d 00 4f 00 00 00 00     69 84 d7 d6 00 00 00 08
        07 00 40 6d 86 cf 1f 46     07 0a 53 70 e2 69 94 a5
        bc 30 58 b2 0d 09 33 ac     70 97 f1 e6 6c 92 46 04
        d5 40 38 a2 20 25 eb 52     21 5e 54 bf 3f ce 8e f9
        7a 7d 4f d2 a1 4f 56 f8     db 51 03 49 e4 c3 2a b9
        d4 20 0f
      BIN
    end

    it 'should NOT decode' do
      expect { ECHConfig::ECHConfigContents::Extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
      expect { ECHConfig::ECHConfigContents::Extensions::ECHAuth.decode(octet.slice(4..) || '') }
        .to raise_error ECHConfig::DecodeError
    end

    it 'should NOT be constructed' do
      expect { ECHConfig::ECHConfigContents::Extensions::ECHAuth.new(0x6984d7d6, 0, '', 0x0807, signature) }
        .to raise_error ArgumentError
    end
  end

  context 'ech_auth, which has no signature' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0d 00 3b 00 00 00 00     69 84 d7 d6 00 00 2c 30
        2a 30 05 06 03 2b 65 70     03 21 00 aa e6 a4 8a 7e
        eb 96 c6 da 22 bb 84 b9     52 85 3e d7 82 50 3f aa
        f8 ac f6 b5 27 ee cd c3     c7 36 3f 08 07 00 00
      BIN
    end

    it 'should NOT decode' do
      expect { ECHConfig::ECHConfigContents::Extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
      expect { ECHConfig::ECHConfigContents::Extensions::ECHAuth.decode(octet.slice(4..) || '') }
        .to raise_error ECHConfig::DecodeError
    end
  end

  context 'ech_auth, which is not the last extension' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0d 00 7b 00 00 00 00     69 84 d7 d6 00 00 2c 30
        2a 30 05 06 03 2b 65 70     03 21 00 aa e6 a4 8a 7e
        eb 96 c6 da 22 bb 84 b9     52 85 3e d7 82 50 3f aa
        f8 ac f6 b5 27 ee cd c3     c7 36 3f 08 07 00 40 6d
        86 cf 1f 46 07 0a 53 70     e2 69 94 a5 bc 30 58 b2
        0d 09 33 ac 70 97 f1 e6     6c 92 46 04 d5 40 38 a2
        20 25 eb 52 21 5e 54 bf     3f ce 8e f9 7a 7d 4f d2
        a1 4f 56 f8 db 51 03 49     e4 c3 2a b9 d4 20 0f 00
        01 00 02 aa bb
      BIN
    end

    it 'should NOT decode' do
      expect { ECHConfig::ECHConfigContents::Extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
    end

    it 'should NOT be constructed' do
      auth = ECHConfig::ECHConfigContents::Extensions::ECHAuth.new(0x6984d7d6, 0, spki, 0x0807, signature)
      unknown = ECHConfig::ECHConfigContents::Extensions::UnknownExtension.new(0x0001, "\xaa\xbb")
      expect { ECHConfig::ECHConfigContents::Extensions.new([auth, unknown]) }.to raise_error ArgumentError
      expect { ECHConfig::ECHConfigContents::Extensions.new([auth]) << unknown }.to raise_error ArgumentError
    end
  end

  context 'ech_auth and ech_authinfo, which are carried by a single ECHConfig' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        fe 0e 00 22 00 20 01 01     01 01 01 01 01 01 01 01
        01 01 01 01 01 01 01 01     01 01 01 01 01 01 01 01
        01 01 01 01 01 01 fe 0d     00 7b 00 00 00 00 69 84
        d7 d6 00 00 2c 30 2a 30     05 06 03 2b 65 70 03 21
        00 aa e6 a4 8a 7e eb 96     c6 da 22 bb 84 b9 52 85
        3e d7 82 50 3f aa f8 ac     f6 b5 27 ee cd c3 c7 36
        3f 08 07 00 40 6d 86 cf     1f 46 07 0a 53 70 e2 69
        94 a5 bc 30 58 b2 0d 09     33 ac 70 97 f1 e6 6c 92
        46 04 d5 40 38 a2 20 25     eb 52 21 5e 54 bf 3f ce
        8e f9 7a 7d 4f d2 a1 4f     56 f8 db 51 03 49 e4 c3
        2a b9 d4 20 0f
      BIN
    end

    it 'should NOT decode' do
      expect { ECHConfig::ECHConfigContents::Extensions.decode(octet) }.to raise_error ECHConfig::DecodeError
    end

    it 'should NOT be constructed' do
      auth = ECHConfig::ECHConfigContents::Extensions::ECHAuth.new(0x6984d7d6, 0, spki, 0x0807, signature)
      info = ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo.new(["\x01" * 32])
      expect { ECHConfig::ECHConfigContents::Extensions.new([info, auth]) }.to raise_error ArgumentError
      expect { ECHConfig::ECHConfigContents::Extensions.new([auth]) << info }.to raise_error ArgumentError
    end
  end

  context 'unknown extension' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        00 01 00 02 aa bb
      BIN
    end

    it 'should decode' do
      exs = ECHConfig::ECHConfigContents::Extensions.decode(octet)
      expect(exs.length).to eq 1

      ex = exs[0x0001]
      expect(ex).to be_a ECHConfig::ECHConfigContents::Extensions::UnknownExtension
      expect(ex.data).to eq "\xaa\xbb"
      expect(exs.any_unsupported_mandatory?).to be false
      expect(exs.encode).to eq octet
    end
  end

  context 'unknown mandatory extension' do
    let(:octet) do
      <<-BIN.split.map(&:hex).map(&:chr).join
        80 01 00 02 aa bb
      BIN
    end

    it 'should decode' do
      exs = ECHConfig::ECHConfigContents::Extensions.decode(octet)
      expect(exs.length).to eq 1

      ex = exs[0x8001]
      expect(ex).to be_a ECHConfig::ECHConfigContents::Extensions::UnknownExtension
      expect(ex.mandatory?).to be true
      expect(exs.any_unsupported_mandatory?).to be true
      expect(exs.encode).to eq octet
    end
  end
end
