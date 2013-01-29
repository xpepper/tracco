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

Bundler.require(:spec)

require 'trello_effort_tracker'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |configuration|
  configuration.include Mongoid::Matchers
end

# force test env for the mongodb configuration
TrelloConfiguration::Database.load_env("test")


## Spec Helper Methods (TODO: should we move them in a separate file?)

def unrecognized_notification
  create_notification(data: { 'text' => '@trackinguser hi there!' })
end

def notification_with_message(message)
  create_notification(data: { 'text' => message })
end

def create_estimate(time_measurement)
  create_notification(data: { 'text' => "@trackinguser [1.5#{TIME_MEASUREMENTS[time_measurement]}]" })
end

def create_effort(time_measurement)
  create_notification(data: { 'text' => "@trackinguser +4.5#{TIME_MEASUREMENTS[time_measurement]}]" })
end

def with(notification)
  tracking = TrackingFactory.build_from(notification)
  yield(tracking)
end

def with_message(notification_message, &block)
  with(notification_with_message(notification_message), &block)
end

def create_notification(custom_params)
  params = { data: { 'text' => "@trackinguser +2h" }, date: "2012-10-28T21:06:14.801Z", member_creator: stub(username: "pietrodibello") }
  params.merge!(custom_params)

  stub(data: params[:data], date: params[:date], member_creator: params[:member_creator]).as_null_object
end

