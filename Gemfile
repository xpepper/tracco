source :rubygems

gemspec

gem 'ruby-trello', :require => 'trello'
# gem 'ruby-trello', :require => 'trello', :path => '../ruby-trello' # to hack on the ruby-trello gem itself

gem 'rainbow'
gem 'chronic'

gem 'mongoid'
gem 'bson_ext'

gem 'google_drive'
gem 'highline'

group :test, :development, :spec do
  gem 'rake'
  gem 'rspec'
  gem 'simplecov', :require => false, :platforms => [:mri, :mri_19]
  gem 'rspec-mocks'
  gem 'mongoid-rspec'
  gem 'database_cleaner'
  gem 'debugger'
end
