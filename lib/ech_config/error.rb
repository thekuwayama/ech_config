# frozen_string_literal: true

# rbs_inline: enabled

# Generic error, common for all classes under ECHConfig module.
class ECHConfig::Error < StandardError; end

# Raised if configure is invalid.
class ECHConfig::DecodeError < ECHConfig::Error; end

# Raised if version is unsupported.
class ECHConfig::UnsupportedVersion < ECHConfig::Error; end
