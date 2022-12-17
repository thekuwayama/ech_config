# frozen_string_literal: true

class ECHConfig::ECHConfigContents::HpkeKeyConfig
  # define class
end

Dir["#{File.dirname(__FILE__)}/hpke_key_config/*.rb"]
  .sort.each { |f| require f }

class ECHConfig::ECHConfigContents::HpkeKeyConfig
  attr_reader :config_id, :kem_id, :public_key, :cipher_suites

  # @param config_id [Integer]
  # @param kem_id [HpkeKemId]
  # @param public_key [HpkePublicKey]
  # @param cipher_suites [Array of HpkeSymmetricCipherSuite]
  def initialize(config_id,
                 kem_id,
                 public_key,
                 cipher_suites)
    @config_id = config_id
    @kem_id = kem_id
    @public_key = public_key
    @cipher_suites = cipher_suites
  end

  # @return [String]
  def encode
    [@config_id].pack('C') \
    + @kem_id.encode \
    + @public_key.encode \
    + @cipher_suites.map(&:encode).join.then { |s| [s.length].pack('n') + s }
  end

  # :nodoc
  # rubocop:disable Metrics/AbcSize
  def self.decode(octet)
    raise ::ECHConfig::DecodeError if octet.empty?

    config_id = octet.slice(0, 1).unpack1('C')
    i = 1
    raise ::ECHConfig::DecodeError if i + 2 > octet.length

    kem_id = HpkeKemId.decode(octet.slice(i, 2))
    i += 2
    raise ::ECHConfig::DecodeError if i + 2 > octet.length

    pk_len = octet.slice(i, 2).unpack1('n')
    i += 2
    raise ::ECHConfig::DecodeError if i + pk_len > octet.length

    public_key = HpkePublicKey.decode(octet.slice(i, pk_len))
    i += pk_len
    raise ::ECHConfig::DecodeError if i + 2 > octet.length

    cs_len = octet.slice(i, 2).unpack1('n')
    i += 2
    raise ::ECHConfig::DecodeError if i + 2 > octet.length

    cs_bin = octet.slice(i, cs_len)
    i += cs_len
    cipher_suites = HpkeSymmetricCipherSuite.decode_vectors(cs_bin)
    hpke_key_config = new(
      config_id,
      kem_id,
      public_key,
      cipher_suites
    )
    [hpke_key_config, octet[i..]]
  end
  # rubocop:enable Metrics/AbcSize
end
