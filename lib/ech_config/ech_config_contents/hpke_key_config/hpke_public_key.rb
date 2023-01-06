# typed: true
# frozen_string_literal: true

class ECHConfig::ECHConfigContents::HpkeKeyConfig::HpkePublicKey
  extend T::Sig
  attr_reader :opaque

  sig { params(opaque: String).void }
  def initialize(opaque)
    @opaque = opaque
  end

  sig { returns(String) }
  def encode
    @opaque.then { |s| [s.length].pack('n') + s }
  end

  sig { params(octet: String).returns(T.attached_class) }
  def self.decode(octet)
    new(octet)
  end
end
