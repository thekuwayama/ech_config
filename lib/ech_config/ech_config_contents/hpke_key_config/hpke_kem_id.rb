# frozen_string_literal: true

class ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkeKemId
  attr_reader :uint16

  # @param uint16 [Integer]
  def initialize(uint16)
    @uint16 = uint16
  end

  # @return [String]
  def encode
    [@uint16].pack('n')
  end

  # :nodoc
  def self.decode(octet)
    raise ::ECHConfig::DecodeError if octet.length != 2

    new(octet.unpack1('n'))
  end
end
