# frozen_string_literal: true

class ECHConfig
  attr_reader :version, :echconfigcontents

  # @param version [String]
  # @param echconfig_contents [ECHConfigContents]
  def initialize(version, echconfig_contents)
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
      raise ::Resolv::DNS::DecodeError if i + 4 > octet.length

      version = octet.slice(i, 2)
      length = octet.slice(i + 2, 2).unpack1('n')
      i += 4
      raise ::Resolv::DNS::DecodeError if i + length > octet.length

      echconfig_contents = ECHConfigContents.decode(octet.slice(i, length))
      i += length
      echconfigs << new(version, echconfig_contents)
    end
    raise ::Resolv::DNS::DecodeError if i != octet.length

    echconfigs
  end
end

require_relative 'ech_config/ech_config_contents'
