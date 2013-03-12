require 'thor'
require 'thor/actions'

module Tracco
  class CLI < Thor
    include Thor::Actions
    desc "console ENVIRONMENT", "Open an irb session preloaded with this library"
    long_desc <<-LONGDESC
      Open an irb session preloaded with this library.
      e.g. 'tracco console production' will open a irb session with the production environment
    LONGDESC
    def console(environment="development")
      error("invalid environment specified: #{environment}") unless is_valid_env?(environment)

      run "export TRACCO_ENV=#{environment}; irb -rubygems -I lib -r tracco -r startup_trello.rb -r awesome_print"
    end
    map %w(c) => :console


    desc "collect STARTING_FROM", "Run tracking data fetching on the cards tracked starting from a given date"
    method_option :environment,         :aliases => "-e", :desc => "the env to use", :default => "development"
    method_option :mongoid_config_path, :aliases => "-m", :desc => "the mongoid config file to use"
    method_option :verbose, :type => :boolean, :aliases => "-v", :default => false
    def collect(starting_date=Date.today.to_s)
      Trello.logger.level = options[:verbose] ? Logger::DEBUG : Logger::WARN
      environment = options[:environment]
      error("invalid environment specified: #{environment}") unless is_valid_env?(environment)

      starting_date = Date.today.to_s if starting_date == "today"
      error("invalid date: #{starting_date}") unless is_valid_date?(starting_date)

      Tracco::Database.load_env(environment, options[:mongoid_config_path])

      puts "collecting tracking data starting from #{starting_date} in the #{environment} env."
      tracker = Tracco::TrelloTracker.new
      tracker.track(Date.parse(starting_date))
    end


    desc "version", "Prints Tracco's version information"
    def version
      say "Tracco version #{Tracco::VERSION}"
    end
    map %w(-v --version) => :version


    private

    def is_valid_env?(environment)
      %w{production development test}.include? environment
    end

    def is_valid_date?(date)
      Date.parse(date) rescue nil
    end

    def error(message)
      say "ERROR: #{message}"
      exit 1
    end
  end
end
