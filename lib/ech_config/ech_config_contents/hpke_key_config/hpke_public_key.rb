# frozen_string_literal: true

class ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkePublicKey
  attr_reader :opaque

  # @param opaque [String]
  def initialize(opaque)
    @opaque = opaque
  end

  # @return [String]
  def encode
    @opaque.then { |s| [s.length].pack('n') + s }
  end

  # :nodoc
  def self.decode(octet)
    new(octet)
  end
end
