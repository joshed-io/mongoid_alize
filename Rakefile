require 'bundler'
require 'rspec/core/rake_task'

desc "Run Rspec unit tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
end

task :default => :spec
task :test => [:spec]
