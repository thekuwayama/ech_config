# frozen_string_literal: true

class ECHConfig
  module Error
    # Generic error, common for all classes under ECHConfig::Error module.
    class Error < StandardError; end

    # Raised if configure is invalid.
    class DecodeError < Error; end
  end
end
