require 'trello'
require 'rainbow'
require 'set'
require 'yaml'
require 'chronic'
require 'mongoid'

require 'trello_effort_tracker/mongoid_helper'
require 'trello_effort_tracker/trello_configuration'
require 'trello_effort_tracker/trello_authorize'
require 'trello_effort_tracker/tracked_card'
require 'trello_effort_tracker/member'
require 'trello_effort_tracker/estimate'
require 'trello_effort_tracker/effort'
require 'trello_effort_tracker/tracking'
require 'trello_effort_tracker/tracking_factory'
require 'trello_effort_tracker/estimate_tracking'
require 'trello_effort_tracker/effort_tracking'
require 'trello_effort_tracker/card_done_tracking'
require 'trello_effort_tracker/invalid_tracking'
require 'trello_effort_tracker/trello_tracker'
require 'trello_effort_tracker/google_docs_exporter'

require 'patches/trello/member'

TrelloConfiguration::Database.load_env(ENV['MONGOID_ENV'] || "development")

Trello.logger.level = Logger::DEBUG