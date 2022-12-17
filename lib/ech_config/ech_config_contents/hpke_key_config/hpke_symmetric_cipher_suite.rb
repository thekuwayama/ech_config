# frozen_string_literal: true

class ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkeSymmetricCipherSuite
  # define class
end

Dir["#{File.dirname(__FILE__)}/hpke_symmetric_cipher_suite/*.rb"]
  .sort.each { |f| require f }

class ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkeSymmetricCipherSuite
  attr_reader :kdf_id, :aead_id

  # @param kdf_id [HpkeKdfId]
  # @param aead_id [HpkeAeadId]
  def initialize(kdf_id, aead_id)
    @kdf_id = kdf_id
    @aead_id = aead_id
  end

  # @return [String]
  def encode
    @kdf_id.encode + @aead_id.encode
  end

  # @return [Array of HpkeSymmetricCipherSuite]
  def self.decode_vectors(octet)
    i = 0
    cipher_suites = []
    while i < octet.length
      raise ::ECHConfig::DecodeError if i + 4 > octet.length

      kdf_id = HpkeKdfId.decode(octet.slice(i, 2))
      aead_id = HpkeAeadId.decode(octet.slice(i + 2, 2))
      i += 4
      cipher_suites << new(kdf_id, aead_id)
    end

    cipher_suites
  end
end
