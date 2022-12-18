# encoding: ascii-8bit
# frozen_string_literal: true

class ECHConfig
  # define class
end

require_relative 'ech_config/error'
require_relative 'ech_config/ech_config_contents'
require_relative 'ech_config/version'

class ECHConfig
  attr_reader :version, :echconfigcontents

  # @param version [String]
  # @param echconfig_contents [ECHConfigContents]
  def initialize(version, echconfig_contents)
    v = version.unpack1('S*')
    # https://author-tools.ietf.org/iddiff?url2=draft-ietf-tls-esni-11.txt#context-3
    raise ::ECHConfig::DecodeError unless v > "\xfe\x0a".unpack1('S*') && v <= "\xfe\x0d".unpack1('S*')

    @version = version
    @echconfig_contents = echconfig_contents
  end

  # @return [String]
  def encode
    @version + @echconfig_contents.encode.then { |s| [s.length].pack('n') + s }
  end

  # @return [Array of ECHConfig]
  def self.decode_vectors(octet)
    i = 0
    echconfigs = []
    while i < octet.length
      raise ::ECHConfig::DecodeError if i + 4 > octet.length

      version = octet.slice(i, 2)
      length = octet.slice(i + 2, 2).unpack1('n')
      i += 4
      raise ::ECHConfig::DecodeError if i + length > octet.length

      echconfig_contents = ECHConfigContents.decode(octet.slice(i, length))
      i += length
      echconfigs << new(version, echconfig_contents)
    end
    raise ::ECHConfig::DecodeError if i != octet.length

    echconfigs
  end
end
