# -*- encoding: utf-8 -*-
require File.expand_path('../lib/trello_effort_tracker/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "trello_effort_tracker"
  gem.description   = "trello_effort_tracker"
  gem.summary       = "trello_effort_tracker"
  gem.authors       = 'Pietro Di Bello'
  gem.email         = 'pierodibello@gmail.com'
  gem.homepage      = 'http://xplayer.wordpress.com'
  gem.require_paths = [ "lib" ]
  gem.version       = TrelloEffortTracker::VERSION
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
end
