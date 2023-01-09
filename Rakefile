# typed: false
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

desc 'Run Sorbet type checker'
task :sorbet do
  sh 'srb tc'
end

task default: %i[rubocop sorbet spec]
