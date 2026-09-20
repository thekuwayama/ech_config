# frozen_string_literal: true

# rbs_inline: enabled

class ECHConfig::ECHConfigContents::Extensions::UnknownExtension
  # an extension can be tagged as mandatory by using an extension type
  # codepoint with the high order bit set to 1.
  # https://datatracker.ietf.org/doc/html/rfc9849.html#section-4.2-2
  MANDATORY_BIT = 0x8000

  attr_reader :type, :data

  # @rbs type: Integer
  # @rbs data: String
  # @rbs return: void
  def initialize(type, data = '')
    @type = type
    @data = data
  end

  # @rbs return: String
  def encode
    [@type].pack('n') + @data.then { |s| [s.length].pack('n') + s }
  end

  # @rbs return: bool
  def mandatory?
    !(@type & MANDATORY_BIT).zero?
  end

  # @rbs other: ECHConfig::ECHConfigContents::Extensions::UnknownExtension
  # @rbs return: bool
  def ==(other)
    other.type == @type && other.data == @data
  end

  # @rbs octet: String
  # @rbs type: Integer
  # @rbs return: ECHConfig::ECHConfigContents::Extensions::UnknownExtension
  def self.decode(octet, type)
    new(type, octet)
  end
end
