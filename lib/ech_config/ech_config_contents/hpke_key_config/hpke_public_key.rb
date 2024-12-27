# frozen_string_literal: true

# rbs_inline: enabled

class ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkePublicKey
  attr_reader :opaque

  # @rbs opaque: String
  # @rbs return: void
  def initialize(opaque)
    @opaque = opaque
  end

  # @rbs return: String
  def encode
    @opaque.then { |s| [s.length].pack('n') + s }
  end

  # @rbs octet: String
  # @rbs return: ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkePublicKey
  def self.decode(octet)
    new(octet)
  end
end
