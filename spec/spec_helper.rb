require 'rubygems'

# Set up gems listed in the Gemfile.
begin
  ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end

Bundler.require

# force test env for the mongodb configuration
ENV['MONGOID_ENV'] = "test"

require 'trello_effort_tracker'

require 'mongoid-rspec'
RSpec.configure do |configuration|
  configuration.include Mongoid::Matchers
end
