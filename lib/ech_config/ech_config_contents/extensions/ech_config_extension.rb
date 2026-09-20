# frozen_string_literal: true

# rbs_inline: enabled

# @rbs module-self _ECHConfigExtension
#
# https://datatracker.ietf.org/doc/html/rfc9849.html#section-4.2
module ECHConfig::ECHConfigContents::Extensions::ECHConfigExtension
  # @rbs!
  #   interface _ECHConfigExtension
  #     def type: () -> Integer
  #
  #     def encode: () -> String
  #   end

  # an extension can be tagged as mandatory by using an extension type
  # codepoint with the high order bit set to 1.
  # https://datatracker.ietf.org/doc/html/rfc9849.html#section-4.2-2
  MANDATORY_BIT = 0x8000

  # @rbs return: bool
  def mandatory?
    !(type & MANDATORY_BIT).zero?
  end
end
