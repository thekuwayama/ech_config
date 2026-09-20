# frozen_string_literal: true

# rbs_inline: enabled

# @rbs inherits Hash[Integer, ECHConfig::ECHConfigContents::Extensions::UnknownExtension]
class ECHConfig::ECHConfigContents::Extensions < Hash
  # define class
end

Dir["#{File.dirname(__FILE__)}/extensions/*.rb"]
  .sort.each { |f| require f }

# https://datatracker.ietf.org/doc/html/rfc9849.html#section-4.2
class ECHConfig::ECHConfigContents::Extensions
  # @rbs extensions: Array[ECHConfig::ECHConfigContents::Extensions::UnknownExtension]
  # @rbs return: void
  def initialize(extensions = [])
    super()
    extensions.each { |ex| self[ex.type] = ex }
  end

  # @rbs return: String
  def encode
    values.map(&:encode).join
  end

  # @rbs ex: ECHConfig::ECHConfigContents::Extensions::UnknownExtension
  # @rbs return: ECHConfig::ECHConfigContents::Extensions::UnknownExtension
  def <<(ex)
    store(ex.type, ex)
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

      ex = UnknownExtension.decode(octet.slice(i + 4, ex_len) || '', type)

      extensions << ex
      i += 4 + ex_len
    end
    raise ::ECHConfig::DecodeError if i != octet.length

    extensions
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
