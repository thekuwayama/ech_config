# typed: true
# frozen_string_literal: true

class ECHConfig::ECHConfigContents::Extension
  extend T::Sig
  attr_reader :octet

  # @param octet [String]
  sig { params(octet: String).void }
  def initialize(octet)
    @octet = octet # TODO
  end

  sig { returns(String) }
  def encode
    @octet # TODO
  end

  sig { params(octet: String).returns(T::Array[T.attached_class]) }
  def self.decode_vectors(octet)
    i = 0
    extensions = []
    while i < octet.length
      raise ::ECHConfig::DecodeError if i + 4 > octet.length

      ex_len = (octet.slice(i + 2, 2) || '').unpack1('n')
      i += 4
      raise ::ECHConfig::DecodeError if i + ex_len > octet.length

      extensions << new(octet.slice(i, ex_len) || '') # TODO
      i += ex_len
    end
    raise ::ECHConfig::DecodeError if i != octet.length

    extensions
  end
end
