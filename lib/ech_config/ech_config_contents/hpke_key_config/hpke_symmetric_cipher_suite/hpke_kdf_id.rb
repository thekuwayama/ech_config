# frozen_string_literal: true

# rbs_inline: enabled

class ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkeSymmetricCipherSuite::HpkeKdfId
  attr_reader :uint16

  # @rbs uint16: Integer
  # @rbs return: void
  def initialize(uint16)
    @uint16 = uint16
  end

  # @rbs return: String
  def encode
    [@uint16].pack('n')
  end

  # @rbs other: HpkeKdfId
  # @rbs return: Boolean
  def ==(other)
    other.uint16 == @uint16
  end

  # @rbs octet: String
  # @rbs return: HpkeKdfId
  def self.decode(octet)
    raise ::ECHConfig::DecodeError if octet.length != 2

    new(octet.unpack1('n'))
  end
end
