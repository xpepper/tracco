desc "Open an irb session preloaded with this library, e.g. rake 'console[production]' will open a irb session with the production db env"
task :console, [:db_env] do |t, args|
  args.with_defaults(db_env: "development")
  sh "export MONGOID_ENV=#{args.db_env}; irb -rubygems -I lib -r tracco.rb -r startup_trello.rb"
end

task :c, [:db_env] do |t, args|
  Rake::Task[:console].invoke(args.db_env)
end

namespace :run do
  include TrelloConfiguration

  desc "Run on the cards tracked starting from a given day, e.g. rake 'run:from_day[2012-11-1]'"
  task :from_day, [:starting_date, :db_env] => [:ensure_environment] do |t, args|
    args.with_defaults(starting_date: Date.today.to_s, db_env: "development")
    TrelloConfiguration::Database.load_env(args.db_env)

    tracker = Tracco::TrelloTracker.new
    tracker.track(Date.parse(args.starting_date))
  end

  desc "Run on the cards tracked today, #{Date.today}"
  task :today, [:db_env] => [:ensure_environment] do |t, args|
    args.with_defaults(db_env: "development")
    Rake.application.invoke_task("run:from_day[#{Date.today.to_s}, #{args.db_env}]")
  end
end

namespace :export do
  desc "Export all cards to a google docs spreadsheet, e.g. rake \"export:google_docs[my_sheet,tracking,production]\""
  task :google_docs, [:spreadsheet, :worksheet, :db_env] => [:ensure_environment] do |t, args|
    args.with_defaults(db_env: "development")
    TrelloConfiguration::Database.load_env(args.db_env)

    exporter = Tracco::GoogleDocsExporter.new(args.spreadsheet, args.worksheet)
    spreadsheet_url = exporter.export

    puts "[DONE]".color(:green)
    puts "Go to #{spreadsheet_url}"
  end
end

task :ensure_environment do
  %w{developer_public_key access_token_key}.each do |each_name|
    unless ENV[each_name] || authorization_params_from_config_file[each_name]
      puts "ERROR: Missing <#{each_name}> configuration parameter: set it as environment variable or in the config/config.yml file."
      exit 1
    end
  end
  unless tracker_username
    puts "ERROR: Missing <tracker_username> configuration parameter: set it as environment variable or in the config/config.yml file."
    exit 1
  end
end
