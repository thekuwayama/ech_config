# typed: strict
# frozen_string_literal: true

require 'base64'
require 'json'
require 'net/http'
require 'uri'

require "#{File.dirname(__FILE__)}/../lib/ech_config"

front = ARGV[0] || 'localhost'
backend = ARGV[1] || 'draft-13.esni.localhost'
uri = URI("https://#{front}/.well-known/ech/#{backend}.json")

res = Net::HTTP.get_response(uri)
unless res.is_a?(Net::HTTPSuccess)
  warn 'error: HTTP Status is not 200'
  exit 1
end

JSON.parse(res.body, symbolize_names: true).each do |h|
  octet = Base64.decode64(h[:echconfiglist])
  unless octet.length - 2 == octet.slice(0, 2)&.unpack1('n')
    warn 'error: failed to parse echconfiglist'
    exit 1
  end

  pp ECHConfig.decode_vectors(octet.slice(2..) || '')
end
