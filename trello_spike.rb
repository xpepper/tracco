$LOAD_PATH.unshift 'lib'

require 'trello_effort_tracker'

tracker = TrelloTracker.new
tracker.track(Date.parse("2012-11-1"))
