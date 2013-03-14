require 'trello'
require 'rainbow'
require 'chronic'
require 'mongoid'
require 'forwardable'

require 'tracco/configuration'

module Tracco
  autoload :TrelloAuthorize, 'tracco/trello_authorize'

  autoload :TrackedCard,     'tracco/models/tracked_card'
  autoload :Member,          'tracco/models/member'
  autoload :Estimate,        'tracco/models/estimate'
  autoload :Effort,          'tracco/models/effort'
  autoload :TrelloTracker,   'tracco/trello_tracker'

  module Tracking
    autoload :Base,             'tracco/tracking/base'
    autoload :EstimateTracking, 'tracco/tracking/estimate_tracking'
    autoload :EffortTracking,   'tracco/tracking/effort_tracking'
    autoload :CardDoneTracking, 'tracco/tracking/card_done_tracking'
    autoload :InvalidTracking,  'tracco/tracking/invalid_tracking'
    autoload :Factory,          'tracco/tracking/factory'
  end

  module Exporters
    autoload :GoogleDocs, 'tracco/exporters/google_docs'
  end

  autoload :CLI, 'tracco/cli'
end

require 'patches/trello/member'
require 'patches/trello/card'

Trello.logger.level = Logger::WARN
Tracco.load_env!
