require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :specs   => :spec

namespace :spec do
  desc "Run fast specs"
  RSpec::Core::RakeTask.new(:fast) do |t|
    t.rspec_opts = '--tag ~needs_valid_configuration'
  end

  desc "Run slow specs"
  RSpec::Core::RakeTask.new(:slow) do |t|
    t.rspec_opts = '--tag needs_valid_configuration'
  end
end
