require 'trello_effort_tracker'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :specs   => :spec
task :c       => :console

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r trello_effort_tracker.rb -r startup_trello.rb"
end

namespace :spec do
  desc "Run fast specs"
  RSpec::Core::RakeTask.new(:fast) do |t|
    t.rspec_opts = '--tag ~needs_valid_configuration'
  end

  desc "Run slow specs"
  RSpec::Core::RakeTask.new(:slow) do |t|
    t.rspec_opts = '--tag needs_valid_configuration'
  end
end

namespace :run do
  include TrelloConfiguration

  desc "Run on the cards tracked starting from a given day, e.g. rake 'run:from_day[2012-11-1]'"
  task :from_day, [:starting_date, :db_env] => [:ensure_environment] do |t, args|
    args.with_defaults(starting_date: Date.today.to_s, db_env: "development")
    TrelloConfiguration::Database.load_env(args.db_env)

    tracker = TrelloTracker.new
    tracker.track(Date.parse(args.starting_date))
  end

  desc "Run on the cards tracked today, #{Date.today}"
  task :today, [:db_env] => [:ensure_environment] do |t, args|
    args.with_defaults(db_env: "development")
    Rake.application.invoke_task("run:from_day[#{Date.today.to_s}, #{args.db_env}]")
  end

  task :ensure_environment do
    %w{developer_public_key developer_secret access_token_key}.each do |each_name|
      unless ENV[each_name] || authorization_params_from_config_file[each_name]
        puts "ERROR: Missing <#{each_name}> environment variable."
        exit 1
      end
    end
    unless tracker_username
      puts "ERROR: Missing <tracker_username> environment variable."
      exit 1
    end

  end
end
