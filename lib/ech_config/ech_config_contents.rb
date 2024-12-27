# frozen_string_literal: true

# rbs_inline: enabled

class ECHConfig::ECHConfigContents
  # define class
end

Dir["#{File.dirname(__FILE__)}/ech_config_contents/*.rb"]
  .sort.each { |f| require f }

class ECHConfig::ECHConfigContents
  attr_reader :key_config, :maximum_name_length, :public_name, :extensions

  # @rbs key_config: ECHConfig::ECHConfigContents::HpkeKeyConfig
  # @rbs maximum_name_length: Integer
  # @rbs public_name: String
  # @rbs extensions: ECHConfig::ECHConfigContents::Extensions
  # @rbs return: void
  def initialize(key_config,
                 maximum_name_length,
                 public_name,
                 extensions)
    @key_config = key_config
    @maximum_name_length = maximum_name_length
    @public_name = public_name
    @extensions = extensions
  end

  # @rbs return: String
  def encode
    @key_config.encode \
    + [@maximum_name_length].pack('C') \
    + @public_name.then { |s| [s.length].pack('C') + s } \
    + @extensions.load.then { |s| [s.length].pack('n') + s }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # @rbs octet: String
  # @rbs return: ECHConfig::ECHConfigContents
  def self.decode(octet)
    key_config, octet = HpkeKeyConfig.decode(octet)
    octet ||= ''
    raise ::ECHConfig::DecodeError if octet.nil? || octet.length < 2

    maximum_name_length = octet.slice(0, 1)&.unpack1('C') #: Integer
    raise ::ECHConfig::DecodeError if maximum_name_length.nil?

    pn_len = octet.slice(1, 1)&.unpack1('C') #: Integer
    i = 2
    raise ::ECHConfig::DecodeError if i + pn_len > octet.length

    public_name = octet.slice(i, pn_len)
    raise ::ECHConfig::DecodeError if public_name.nil?

    i += pn_len
    raise ::ECHConfig::DecodeError if i + 2 > octet.length

    ex_len = octet.slice(i, 2)&.unpack1('n') #: Integer
    i += 2
    raise ::ECHConfig::DecodeError if i + ex_len != octet.length

    extensions = Extensions.store(octet.slice(i, ex_len) || '')
    new(
      key_config,
      maximum_name_length,
      public_name,
      extensions
    )
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
