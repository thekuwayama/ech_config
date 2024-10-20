# frozen_string_literal: true

# rbs_inline: enabled

class ECHConfig::ECHConfigContents::Extensions
  attr_reader :octet

  # @rbs octet: String
  # @rbs return: void
  def initialize(octet)
    # Note taht ECHConfig::ECHConfigContents::Extension only has octets.
    # If you need, deserialize octets to get TLS Extension objects.
    @octet = octet
  end

  # @rbs return: String
  def load
    @octet
  end

  # @rbs octet: String
  # @rbs return: Extensions
  def self.store(octet)
    new(octet)
  end
end
