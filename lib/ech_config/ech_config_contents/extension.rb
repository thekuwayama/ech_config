# frozen_string_literal: true

class ECHConfig::ECHConfigContents::Extension
  attr_reader :octet

  # @param octet [String]
  def initialize(octet)
    @octet = octet # TODO
  end

  # @return [String]
  def encode
    @octet # TODO
  end

  # @return [Array of Extension]
  def self.decode_vectors(octet)
    i = 0
    extensions = []
    while i < octet.length
      raise ::ECHConfig::DecodeError if i + 4 > octet.length

      ex_len = octet.slice(i + 2, 2)
      i += 4
      raise ::ECHConfig::DecodeError if i + ex_len > octet.length

      extensions << new(octet.slice(i, ex_len)) # TODO
      i += ex_len
    end
    raise ::ECHConfig::DecodeError if i != octet.length

    extensions
  end
end
