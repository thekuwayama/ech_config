# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ech_config/version'

Gem::Specification.new do |spec|
  spec.name          = 'ech_config'
  spec.version       = ECHConfig::VERSION
  spec.authors       = ['thekuwayama']
  spec.email         = ['thekuwayama@gmail.com']
  spec.summary       = 'ECHConfig'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/thekuwayama/ech_config'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>=2.7.0'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_runtime_dependency 'sorbet-runtime'
end
