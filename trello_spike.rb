$LOAD_PATH.unshift 'lib'

require 'trello_tracker'

tracker = TrelloTracker.new
tracker.track
