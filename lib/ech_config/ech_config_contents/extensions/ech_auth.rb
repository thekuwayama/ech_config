# encoding: ascii-8bit
# frozen_string_literal: true

# rbs_inline: enabled

# https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1
class ECHConfig::ECHConfigContents::Extensions::ECHAuth
  include ECHConfig::ECHConfigContents::Extensions::ECHConfigExtension

  # Value: TBD2 (assigned with the high-order bit set)
  # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-9.1-5.1.1
  #
  # TODO: placeholder until IANA assigns TBD2. 0xfe0d is the codepoint
  # ech-auth-interop uses for ech_auth.
  # https://github.com/grittygrease/ech-auth-interop
  TYPE = 0xfe0d

  # context_label = "TLS-ECH-AUTH-v1"
  # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1.1-2
  CONTEXT_LABEL = 'TLS-ECH-AUTH-v1'

  # uint64 not_after, uint8 disable and the length prefix of spki
  FIXED_LENGTH = 8 + 1 + 2

  attr_reader :not_after, :spki, :algorithm, :signature

  # @rbs not_after: Integer
  # @rbs disable: Integer
  # @rbs spki: String
  # @rbs algorithm: Integer
  # @rbs signature: String
  # @rbs return: void
  def initialize(not_after, disable, spki, algorithm, signature)
    # Senders MUST encode disable as 0 or 1; clients MUST reject any other
    # value.
    # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1-7
    raise ArgumentError unless [0, 1].include?(disable)

    # opaque spki<1..2^16-1>;
    raise ArgumentError if spki.empty? || spki.length > 2**16 - 1

    # opaque signature<0..2^16-1>;
    raise ArgumentError if signature.length > 2**16 - 1

    @not_after = not_after
    @disable = disable
    @spki = spki
    @algorithm = algorithm
    @signature = signature
  end

  # @rbs return: Integer
  def type
    TYPE
  end

  # When set to 1, the client MUST NOT attempt ECH on the retry.
  # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1-7
  #
  # @rbs return: bool
  def disable?
    @disable == 1
  end

  # @rbs return: String
  def encode
    [TYPE].pack('n') \
    + ([@not_after].pack('Q>') \
       + [@disable].pack('C') \
       + @spki.then { |s| [s.length].pack('n') + s } \
       + [@algorithm].pack('n') \
       + @signature.then { |s| [s.length].pack('n') + s })
      .then { |s| [s.length].pack('n') + s } # ECHConfigExtension.data
  end

  # The two-byte length prefix of the signature field is encoded as 0x0000 and
  # no signature bytes follow.
  # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1.1-4.1
  #
  # @rbs return: ECHConfig::ECHConfigContents::Extensions::ECHAuth
  def without_signature
    self.class.new(@not_after, @disable, @spki, @algorithm, '')
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # @rbs octet: String
  # @rbs return: ECHConfig::ECHConfigContents::Extensions::ECHAuth
  def self.decode(octet)
    raise ::ECHConfig::DecodeError if octet.length < FIXED_LENGTH

    not_after = octet.slice(0, 8)&.unpack1('Q>') #: Integer
    disable = octet.slice(8, 1)&.unpack1('C') #: Integer
    # Senders MUST encode disable as 0 or 1; clients MUST reject any other
    # value.
    # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1-7
    raise ::ECHConfig::DecodeError unless [0, 1].include?(disable)

    spki_len = octet.slice(9, 2)&.unpack1('n') #: Integer
    i = 11
    # opaque spki<1..2^16-1>;
    raise ::ECHConfig::DecodeError \
      if spki_len.zero? || i + spki_len + 4 > octet.length

    spki = octet.slice(i, spki_len) #: String
    i += spki_len
    algorithm = octet.slice(i, 2)&.unpack1('n') #: Integer
    i += 2
    sig_len = octet.slice(i, 2)&.unpack1('n') #: Integer
    i += 2
    raise ::ECHConfig::DecodeError if i + sig_len != octet.length
    # The signature field in a wire ECHAuth MUST be non-empty. The zero-length
    # form is used only when constructing ECHConfigTBS.
    # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1-6
    raise ::ECHConfig::DecodeError if sig_len.zero?

    new(not_after, disable, spki, algorithm, octet.slice(i, sig_len) || '')
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
