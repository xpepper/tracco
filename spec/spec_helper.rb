require 'rubygems'

require 'simplecov'
SimpleCov.start

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

ENV['TRACCO_ENV'] = "test"
require 'tracco'

require 'factory_girl'
FactoryGirl.find_definitions

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |configuration|
  configuration.include Mongoid::Matchers
  configuration.include FactoryGirl::Syntax::Methods # Repeating "FactoryGirl" is too verbose for me...
end
