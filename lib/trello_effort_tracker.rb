require 'trello'
require 'rainbow'
require 'set'
require 'yaml'
require 'chronic'
# require 'forwardable'
require 'mongoid'

require 'trello_effort_tracker/trello_configuration'
require 'trello_effort_tracker/trello_authorize'
require 'trello_effort_tracker/tracked_card'
require 'trello_effort_tracker/estimate'
require 'trello_effort_tracker/effort'
require 'trello_effort_tracker/tracking'
require 'trello_effort_tracker/trello_tracker'

Mongoid.load!("config/mongoid.yml", :development)