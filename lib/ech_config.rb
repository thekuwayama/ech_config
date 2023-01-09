# encoding: ascii-8bit
# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

class ECHConfig
  # define class
end

require_relative 'ech_config/error'
require_relative 'ech_config/ech_config_contents'
require_relative 'ech_config/version'

class ECHConfig
  extend T::Sig
  attr_reader :version, :echconfig_contents

  private_class_method :new

  @version = T.let(nil, T.nilable(String))
  @echconfig_contents = T.let(nil, T.nilable(ECHConfigContents))

  def initialize(version, echconfig_contents)
    v = version.unpack1('n')
    # https://author-tools.ietf.org/iddiff?url2=draft-ietf-tls-esni-11.txt#context-3
    raise ::ECHConfig::Error unless v > "\xfe\x0a".unpack1('n') && v <= "\xfe\x0d".unpack1('n')

    @version = version
    @echconfig_contents = echconfig_contents
  end

  sig { returns(String) }
  def encode
    @version + @echconfig_contents.encode.then { |s| [s.length].pack('n') + s }
  end

  sig { params(octet: String).returns(T::Array[T.attached_class]) }
  # rubocop:disable Metrics/CyclomaticComplexity
  def self.decode_vectors(octet)
    i = 0
    echconfigs = []
    while i < octet.length
      raise ::ECHConfig::DecodeError if i + 4 > octet.length

      version = octet.slice(i, 2)
      raise ::ECHConfig::DecodeError if version.nil?

      length = octet.slice(i + 2, 2)&.unpack1('n')
      i += 4
      raise ::ECHConfig::DecodeError if i + length > octet.length

      echconfig_contents = ECHConfigContents.decode(octet.slice(i, length) || '')
      i += length
      echconfigs << new(version, echconfig_contents)
    end
    raise ::ECHConfig::DecodeError if i != octet.length

    echconfigs
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
