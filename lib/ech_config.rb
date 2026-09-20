# encoding: ascii-8bit
# frozen_string_literal: true

# rbs_inline: enabled

require 'base64'

class ECHConfig
  # define class
end

require_relative 'ech_config/error'
require_relative 'ech_config/ech_config_contents'
require_relative 'ech_config/version'

class ECHConfig
  attr_reader :version, :echconfig_contents

  # @rbs version: String
  # @rbs echconfig_contents: ECHConfig::ECHConfigContents
  # @rbs return: void
  def initialize(version, echconfig_contents)
    v = version.unpack1('n')
    # https://datatracker.ietf.org/doc/html/rfc9849#section-4
    raise ::ECHConfig::UnsupportedVersion \
      unless v > "\xfe\x0a".unpack1('n') && v <= "\xfe\x0d".unpack1('n') # steep:ignore

    @version = version
    @echconfig_contents = echconfig_contents
  end

  # @rbs return: String
  def encode
    @version + @echconfig_contents.encode.then { |s| [s.length].pack('n') + s }
  end

  # to_be_signed = context_label || ECHConfigTBS
  # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1.1-2
  #
  # ECHConfigTBS (To-Be-Signed) is a fresh serialization of the ECHConfig
  # structure including the ech_auth extension, but with the signature field
  # within ech_auth set to zero-length. The ech_auth extension data length,
  # ECHConfig extensions vector length, and ECHConfig length field are
  # recomputed for that serialization.
  # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1.1-4.1
  #
  # @rbs return: String
  def to_be_signed
    ech_auth = @echconfig_contents.extensions[ECHConfigContents::Extensions::ECHAuth::TYPE]
    raise ::ECHConfig::Error \
      unless ech_auth.is_a?(ECHConfigContents::Extensions::ECHAuth)

    extensions = ECHConfigContents::Extensions.new(
      @echconfig_contents.extensions.values.map do |ex|
        ex.equal?(ech_auth) ? ech_auth.without_signature : ex
      end
    )
    ECHConfigContents::Extensions::ECHAuth::CONTEXT_LABEL \
    + self.class.new(
      @version,
      ECHConfigContents.new(
        @echconfig_contents.key_config,
        @echconfig_contents.maximum_name_length,
        @echconfig_contents.public_name,
        extensions
      )
    ).encode
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # @rbs octet: String
  # @rbs return: Array[ECHConfig]
  def self.decode_vectors(octet)
    i = 0
    echconfigs = [] # @type var echconfigs: Array[ECHConfig]
    while i < octet.length
      raise ::ECHConfig::DecodeError if i + 4 > octet.length

      version = octet.slice(i, 2)
      raise ::ECHConfig::DecodeError if version.nil?

      length = octet.slice(i + 2, 2)&.unpack1('n') # @type var length: Integer
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

class ECHConfigList
  # @rbs echconfigs: Array[ECHConfig]
  # @rbs return: void
  def initialize(echconfigs)
    @echconfigs = echconfigs
  end

  # @rbs return: String
  def encode
    @echconfigs.map(&:encode).join.then { |s| [s.length].pack('n') + s }
  end

  # @rbs return: String
  def to_pem
    body = Base64.strict_encode64(encode).scan(/.{1,64}/).join("\n")

    # https://datatracker.ietf.org/doc/html/rfc9934#section-3
    <<~PEM
      -----BEGIN ECHCONFIG-----
      #{body}
      -----END ECHCONFIG-----
    PEM
  end
end
