# typed: false
# frozen_string_literal: true

class ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkeSymmetricCipherSuite::HpkeAeadId
  extend T::Sig
  attr_reader :uint16

  def initialize(uint16)
    @uint16 = uint16
  end

  sig { returns(String) }
  def encode
    [@uint16].pack('n')
  end

  sig { params(other: T.self_type).returns(T::Boolean) }
  def ==(other)
    other.uint16 == @uint16
  end

  sig { params(octet: String).returns(T.attached_class) }
  def self.decode(octet)
    raise ::ECHConfig::DecodeError if octet.length != 2

    new(octet.unpack1('n'))
  end
end
