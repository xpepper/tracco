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

RSpec.configure do |configuration|
  configuration.include Mongoid::Matchers
end

# force test env for the mongodb configuration
TrelloConfiguration::Database.load_env("test")

def create_notification(custom_params)
  params = { data: { 'text' => "@trackinguser +2h" }, date: "2012-10-28T21:06:14.801Z", member_creator: stub(username: "pietrodibello") }
  params.merge!(custom_params)

  stub(data: params[:data], date: params[:date], member_creator: params[:member_creator]).as_null_object
end
