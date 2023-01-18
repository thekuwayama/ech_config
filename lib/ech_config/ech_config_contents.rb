# typed: true
# frozen_string_literal: true

class ECHConfig::ECHConfigContents
  # define class
end

Dir["#{File.dirname(__FILE__)}/ech_config_contents/*.rb"]
  .sort.each { |f| require f }

class ECHConfig::ECHConfigContents
  extend T::Sig
  attr_reader :key_config, :maximum_name_length, :public_name, :extensions

  sig do
    params(
      key_config: HpkeKeyConfig,
      maximum_name_length: Integer,
      public_name: String,
      extensions: Extensions
    ).void
  end
  def initialize(key_config,
                 maximum_name_length,
                 public_name,
                 extensions)
    @key_config = key_config
    @maximum_name_length = maximum_name_length
    @public_name = public_name
    @extensions = extensions
  end

  sig { returns(String) }
  def encode
    @key_config.encode \
    + [@maximum_name_length].pack('C') \
    + @public_name.then { |s| [s.length].pack('C') + s } \
    + @extensions.load.then { |s| [s.length].pack('n') + s }
  end

  sig { params(octet: String).returns(T.attached_class) }
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def self.decode(octet)
    key_config, octet = HpkeKeyConfig.decode(octet)
    raise ::ECHConfig::DecodeError if octet.nil?
    raise ::ECHConfig::DecodeError if octet.length < 2

    maximum_name_length = octet.slice(0, 1)&.unpack1('C')
    raise ::ECHConfig::DecodeError if maximum_name_length.nil?

    pn_len = octet.slice(1, 1)&.unpack1('C')
    i = 2
    raise ::ECHConfig::DecodeError if i + pn_len > octet.length

    public_name = octet.slice(i, pn_len)
    raise ::ECHConfig::DecodeError if public_name.nil?

    i += pn_len
    raise ::ECHConfig::DecodeError if i + 2 > octet.length

    ex_len = octet.slice(i, 2)&.unpack1('n')
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
