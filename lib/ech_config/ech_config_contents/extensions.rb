# frozen_string_literal: true

# rbs_inline: enabled

# @rbs inherits Hash[Integer, ECHConfig::ECHConfigContents::Extensions::ECHConfigExtension]
class ECHConfig::ECHConfigContents::Extensions < Hash
  # define class
end

# ech_config_extension.rb needs to be loaded first so that each extension can
# include it
require_relative 'extensions/ech_config_extension'

Dir["#{File.dirname(__FILE__)}/extensions/*.rb"]
  .sort.each { |f| require f }

# https://datatracker.ietf.org/doc/html/rfc9849.html#section-4.2
class ECHConfig::ECHConfigContents::Extensions
  # @rbs extensions: Array[ECHConfig::ECHConfigContents::Extensions::ECHConfigExtension]
  # @rbs return: void
  def initialize(extensions = [])
    super()
    extensions.each { |ex| self << ex }
  end

  # @rbs return: String
  def encode
    values.map(&:encode).join
  end

  # @rbs ex: ECHConfig::ECHConfigContents::Extensions::ECHConfigExtension
  # @rbs return: self
  def <<(ex)
    raise ArgumentError unless self.class.valid_order?(keys | [ex.type])

    store(ex.type, ex)
    self
  end

  # A single ECHConfig MUST NOT carry both extensions.
  # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1-2
  #
  # The ech_auth extension MUST be the last extension in the ECHConfig's
  # extension list.
  # https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1-3
  #
  # @rbs types: Array[Integer]
  # @rbs return: bool
  def self.valid_order?(types)
    return true unless types.include?(ECHAuth::TYPE)

    !types.include?(ECHAuthInfo::TYPE) && types.last == ECHAuth::TYPE
  end

  # Clients MUST parse the extension list and check for unsupported mandatory extensions.
  # If an unsupported mandatory extension is present, clients MUST ignore the ECHConfig.
  # https://datatracker.ietf.org/doc/html/rfc9849.html#section-4.2-2
  #
  # @rbs return: bool
  def any_mandatory?
    values.any?(&:mandatory?)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # @rbs octet: String
  # @rbs return: ECHConfig::ECHConfigContents::Extensions
  def self.decode(octet)
    i = 0
    extensions = new
    while i < octet.length
      raise ::ECHConfig::DecodeError if i + 4 > octet.length

      type = octet.slice(i, 2)&.unpack1('n') #: Integer
      ex_len = octet.slice(i + 2, 2)&.unpack1('n') #: Integer
      raise ::ECHConfig::DecodeError if i + 4 + ex_len > octet.length

      # There MUST NOT be more than one extension of the same type.
      raise ::ECHConfig::DecodeError if extensions.include?(type)

      ex = decode_extension(octet.slice(i + 4, ex_len) || '', type)
      extensions.store(type, ex)
      i += 4 + ex_len
    end
    raise ::ECHConfig::DecodeError if i != octet.length
    raise ::ECHConfig::DecodeError unless valid_order?(extensions.keys)

    extensions
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  # @rbs octet: String
  # @rbs type: Integer
  # @rbs return: ECHConfig::ECHConfigContents::Extensions::ECHConfigExtension
  def self.decode_extension(octet, type)
    case type
    when ECHAuth::TYPE then ECHAuth.decode(octet)
    when ECHAuthInfo::TYPE then ECHAuthInfo.decode(octet)
    else UnknownExtension.decode(octet, type)
    end
  end
  private_class_method :decode_extension
end
