# typed: strict
# frozen_string_literal: true

# Generic error, common for all classes under ECHConfig module.
class ECHConfig::Error < StandardError; end

# Raised if configure is invalid.
class ECHConfig::DecodeError < ECHConfig::Error; end
