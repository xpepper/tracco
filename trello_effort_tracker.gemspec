# -*- encoding: utf-8 -*-
require File.expand_path('../lib/trello_effort_tracker/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "trello_effort_tracker"
  gem.description   = "A tool to extract estimates and efforts from Trello"
  gem.summary       = "You notify all the estimates and efforts of your Trello cards. This tool will extract and store these estimates and actual efforts to let you extract useful key metrics (e.g. estimate errors)"
  gem.authors       = 'Pietro Di Bello'
  gem.email         = 'pierodibello@gmail.com'
  gem.homepage      = 'http://xplayer.wordpress.com'
  gem.require_paths = [ "lib" ]
  gem.version       = TrelloEffortTracker::VERSION
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
end
