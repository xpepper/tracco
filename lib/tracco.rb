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

TrelloConfiguration::Database.load_env(ENV['MONGOID_ENV'] || "development", ENV['MONGOID_CONFIG_PATH'])

Trello.logger.level = Logger::DEBUG
