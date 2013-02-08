# encoding: utf-8
require 'bundler'
require 'trello_effort_tracker'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :specs   => :spec

import 'lib/tasks/tasks.rake'
