# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

desc 'Generate RBS signatures for `lib` files'
task :rbs_inline do
  sh 'rbs-inline', 'lib', '--output=sig/generated'
end

namespace :steep do
  desc 'Run `steep check`'
  task :check do
    sh 'steep', 'check'
  end
end

task default: %i[rubocop spec rbs_inline steep:check]
