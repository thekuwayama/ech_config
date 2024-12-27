# frozen_string_literal: true

# rbs_inline: enabled

class ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkeSymmetricCipherSuite::HpkeAeadId
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

  # @rbs other: ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkeSymmetricCipherSuite::HpkeAeadId
  # @rbs return: bool
  def ==(other)
    other.uint16 == @uint16
  end

  # @rbs octet: String
  # @rbs return: ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkeSymmetricCipherSuite::HpkeAeadId
  def self.decode(octet)
    raise ::ECHConfig::DecodeError if octet.length != 2

    id = octet.unpack1('n') #: Integer
    new(id)
  end
end
