# typed: true
# frozen_string_literal: true

class ECHConfig::ECHConfigContents::Extensions
  extend T::Sig
  attr_reader :octet

  sig { params(octet: String).void }
  def initialize(octet)
    # Note taht ECHConfig::ECHConfigContents::Extension only has octets.
    # If you need, deserialize octets to get TLS Extension objects.
    @octet = octet
  end

  sig { returns(String) }
  def load
    @octet
  end

  sig { params(octet: String).returns(T.attached_class) }
  def self.store(octet)
    new(octet)
  end
end
