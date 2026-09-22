# frozen_string_literal: true

# rbs_inline: enabled

# https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1
class ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo
  include ECHConfig::ECHConfigContents::Extensions::ECHConfigExtension

  # Value: TBD1 (assigned with the high-order bit set)
  # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-9.1-3.1.1
  #
  # TODO: placeholder until IANA assigns TBD1, NOT interoperable.
  TYPE = 0xfe0e

  # opaque SPKIHash[32];
  SPKI_HASH_LENGTH = 32

  attr_reader :trusted_keys

  # @rbs trusted_keys: Array[String]
  # @rbs return: void
  def initialize(trusted_keys)
    # SPKIHash trusted_keys<32..2^16-32>;
    raise ArgumentError unless trusted_keys.all? { |k| k.length == SPKI_HASH_LENGTH }
    raise ArgumentError \
      if trusted_keys.empty? ||
         trusted_keys.length * SPKI_HASH_LENGTH > 2**16 - SPKI_HASH_LENGTH

    @trusted_keys = trusted_keys
  end

  # @rbs return: Integer
  def type
    TYPE
  end

  # @rbs return: String
  def encode
    [TYPE].pack('n') \
    + @trusted_keys.join
                   .then { |s| [s.length].pack('n') + s } # ECHAuthInfo.trusted_keys
                   .then { |s| [s.length].pack('n') + s } # ECHConfigExtension.data
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # @rbs octet: String
  # @rbs return: ECHConfig::ECHConfigContents::Extensions::ECHAuthInfo
  def self.decode(octet)
    raise ::ECHConfig::DecodeError if octet.length < 2

    # SPKIHash trusted_keys<32..2^16-32>;
    tk_len = octet.slice(0, 2)&.unpack1('n') #: Integer
    raise ::ECHConfig::DecodeError if tk_len + 2 != octet.length
    raise ::ECHConfig::DecodeError \
      if tk_len < SPKI_HASH_LENGTH || tk_len > 2**16 - SPKI_HASH_LENGTH
    raise ::ECHConfig::DecodeError unless (tk_len % SPKI_HASH_LENGTH).zero?

    trusted_keys = (0...(tk_len / SPKI_HASH_LENGTH)).map do |i|
      octet.slice(2 + i * SPKI_HASH_LENGTH, SPKI_HASH_LENGTH) || ''
    end
    new(trusted_keys)
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
