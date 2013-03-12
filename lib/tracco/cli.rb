require 'thor'
require 'thor/actions'
require 'tracco/trello_configuration'

module Tracco
  class CLI < Thor
    include Thor::Actions
    include TrelloConfiguration

    desc "console", "Opens an irb session preloaded with Tracco gem"
    long_desc <<-LONGDESC
      Opens an irb session preloaded with this library.
      e.g. 'tracco console production' will open a irb session with the production environment
    LONGDESC
    method_option :environment, :aliases => "-e", :desc => "the env to use", :default => "development"
    def console
      environment = environment_from(options)

      run "export TRACCO_ENV=#{environment}; irb -rubygems -I lib -r tracco -r startup_trello.rb -r awesome_print"
    end
    map %w(c) => :console


    desc "collect STARTING_FROM", "Runs tracking data fetching on the cards tracked starting from a given date"
    method_option :environment,         :aliases => "-e", :desc => "the env to use", :default => "development"
    method_option :mongoid_config_path, :aliases => "-m", :desc => "the mongoid config file to use"
    method_option :verbose, :type => :boolean, :aliases => "-v", :default => false
    def collect(starting_date=Date.today.to_s)
      set_logger_level(options[:verbose])
      invoke :ensure_env

      starting_date = Date.today.to_s if starting_date == "today"
      error("Invalid date: #{starting_date}") unless is_valid_date?(starting_date)

      environment = environment_from(options)
      Tracco::Database.load_env(environment, options[:mongoid_config_path])

      puts "Collecting tracking data starting from #{starting_date} in the #{environment} env."
      tracker = Tracco::TrelloTracker.new
      tracker.track(Date.parse(starting_date))
    end

    desc "export_google_docs SPREADSHEET_NAME WORKSHEET_NAME", "Exports tracking data to google docs"
    method_option :environment,         :aliases => "-e", :desc => "the env to use", :default => "development"
    method_option :mongoid_config_path, :aliases => "-m", :desc => "the mongoid config file to use"
    method_option :verbose, :type => :boolean, :aliases => "-v", :default => false
    def export_google_docs(spreadsheet="tracco", worksheet="tracking")
      set_logger_level(options[:verbose])
      invoke :ensure_env

      environment = environment_from(options)
      Tracco::Database.load_env(environment, options[:mongoid_config_path])

      exporter = Tracco::Exporters::GoogleDocs.new(spreadsheet, worksheet)
      spreadsheet_url = exporter.export
      say "[DONE]".color(:green)
      say "Go to #{spreadsheet_url}"
    end
    map %w(egd) => :export_google_docs


    desc "version", "Prints Tracco's version information"
    def version
      say "Tracco version #{Tracco::VERSION}"
    end
    map %w(-v --version) => :version

    desc "ensure_env", "Ensures the environment is valid and prints the current configuration params"
    def ensure_env(*args)
      %w{developer_public_key access_token_key}.each do |each_name|
        unless ENV[each_name] || authorization_params_from_config_file[each_name]
          error("Missing <#{each_name}> configuration parameter: set it as environment variable or in the config/config.yml file.")
        end
      end
      unless tracker_username
        error("Missing <tracker_username> configuration parameter: set it as environment variable or in the config/config.yml file.")
      end
    end
    map %w(check_env) => :ensure_environment

    private

    def set_logger_level(verbose)
      Trello.logger.level = verbose ? Logger::DEBUG : Logger::INFO
    end

    def environment_from(options)
      environment = options[:environment]
      error_invalid_environment(environment) unless is_valid_env?(environment)

      return environment
    end

    def is_valid_env?(environment)
      %w{production development test}.include? environment
    end

    def is_valid_date?(date)
      Date.parse(date) rescue nil
    end

    def error(message)
      say "[ERROR] ".color(:red) << message
      exit 1
    end

    def error_invalid_environment(environment)
      error("Invalid environment specified: #{environment}")
    end
  end
end
