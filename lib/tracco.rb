require 'trello'
require 'rainbow'
require 'set'
require 'yaml'
require 'chronic'
require 'mongoid'
require 'forwardable'

require 'tracco/mongoid_helper'
require 'tracco/trello_configuration'
require 'tracco/trello_authorize'
require 'tracco/models/tracked_card'
require 'tracco/models/member'
require 'tracco/models/estimate'
require 'tracco/models/effort'
require 'tracco/tracking/base'
require 'tracco/tracking/estimate_tracking'
require 'tracco/tracking/effort_tracking'
require 'tracco/tracking/card_done_tracking'
require 'tracco/tracking/invalid_tracking'
require 'tracco/tracking/factory'
require 'tracco/trello_tracker'
require 'tracco/exporters/google_docs'

require 'patches/trello/member'
require 'patches/trello/card'

module Tracco
  def self.environment
    ENV['TRACCO_ENV']
  end

  def self.environment=(env_name)
    ENV['TRACCO_ENV'] = env_name.to_s
  end
end

begin
  TrelloConfiguration::Database.load_env(Tracco.environment || "development", ENV['MONGOID_CONFIG_PATH'])
rescue Errno::ENOENT => e
  puts e.message
  puts "try running 'rake prepare'"
end

Trello.logger.level = Logger::DEBUG
