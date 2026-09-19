# frozen_string_literal: true

# rbs_inline: enabled

class ECHConfig::ECHConfigContents::Extensions
  attr_reader :octet

  # @rbs octet: String
  # @rbs return: void
  def initialize(octet)
    # TODO: `ECHConfigExtension extensions<0..2^16-1>`
    # as opaque octets, without the 2-octet length prefix. Each element is
    # an ECHConfigExtension (2-octet type + opaque data<0..2^16-1>).
    # https://datatracker.ietf.org/doc/html/rfc9849.html#section-4.2
    @octet = octet
  end

  # @rbs return: String
  def load
    @octet
  end

  # @rbs octet: String
  # @rbs return: ECHConfig::ECHConfigContents::Extensions
  def self.store(octet)
    new(octet)
  end
end
