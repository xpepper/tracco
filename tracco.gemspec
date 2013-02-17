# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tracco/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name              = "tracco"
  gem.version           = TrelloEffortTracker::VERSION
  gem.platform          = Gem::Platform::RUBY

  gem.description       = "Tracco is a Trello effort tracker: the purpose of Tracco is to extract and track estimates and actual efforts out of the cards on your Trello boards."
  gem.summary           = <<-DESC
    You notify all the estimates and efforts of your Trello cards.
    This tool will extract and store these estimates and actual efforts
    to let you extract useful key metrics (e.g. estimate errors)
  DESC
  gem.authors           = ['Pietro Di Bello']
  gem.email             = 'pierodibello@gmail.com'
  gem.homepage          = 'http://xplayer.github.com'
  gem.date              = Time.now.strftime "%Y-%m-%d"

  gem.require_paths     = ["lib"]
  gem.files             = `git ls-files`.split("\n")
  gem.test_files        = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files  = ["README.md"]

  gem.required_rubygems_version = ">= 1.3.6"

  gem.add_runtime_dependency 'ruby-trello'
  gem.add_runtime_dependency 'mongoid'
  gem.add_runtime_dependency 'bson_ext'
  gem.add_runtime_dependency 'google_drive'
  gem.add_runtime_dependency 'rainbow'
  gem.add_runtime_dependency 'chronic'
  gem.add_runtime_dependency 'highline'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-mocks'
  gem.add_development_dependency 'mongoid-rspec'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'debugger'
end
