# frozen_string_literal: true

# rbs_inline: enabled

class ECHConfig::ECHConfigContents::Extensions::UnknownExtension
  include ECHConfig::ECHConfigContents::Extensions::ECHConfigExtension

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
  def supported?
    false
  end

  # @rbs octet: String
  # @rbs type: Integer
  # @rbs return: ECHConfig::ECHConfigContents::Extensions::UnknownExtension
  def self.decode(octet, type)
    new(type, octet)
  end
end
