require 'thor'
require 'thor/actions'

module Tracco
  class CLI < Thor
    include Thor::Actions
    include TrelloConfiguration

    def self.source_root
      File.join(File.dirname(__FILE__), "..", "..", "config")
    end

    map "c" => :console
    map %w(track t) => :collect
    map "egd" => :export_google_docs
    map "check_env" => :ensure_env
    map %w(-v --version) => :version
    map %w(initialize --initialize) => :init

    desc "console", "Opens up an irb session preloaded with Tracco gem"
    long_desc <<-LONGDESC
      Opens up an irb session preloaded with this library.
      e.g. 'tracco console production' will open a irb session with the production environment
    LONGDESC
    method_option :environment, :aliases => "-e", :desc => "the env to use", :default => "development"
    def console
      environment = environment_from(options)
      run "export TRACCO_ENV=#{environment}; irb -rubygems -I lib -r tracco -r startup_trello.rb -r awesome_print"
    end


    desc "collect STARTING_FROM", "Runs tracking data fetching on the cards tracked starting from a given date"
    long_desc <<-LONGDESC
      Runs tracking data fetching on the cards tracked starting from a given date.
      e.g. 'tracco 2013.03.23' will start collecting tracking data starting from March 23, 2013.
    LONGDESC
    method_option :environment,         :aliases => "-e", :desc => "the env to use", :default => "development"
    method_option :mongoid_config_path, :aliases => "-m", :desc => "the mongoid config file to use"
    method_option :verbose,             :aliases => "-v", :type => :boolean, :default => false
    def collect(starting_date_as_string=Date.today.to_s)
      set_logger_level(options[:verbose])
      invoke :ensure_env

      starting_date = date_from(starting_date_as_string)
      environment = environment_from(options)
      Tracco::Database.load_env(environment, options[:mongoid_config_path])

      puts "Collecting tracking data starting from #{starting_date} in the #{environment} env."
      tracker = Tracco::TrelloTracker.new
      tracker.track(starting_date)
    end

    desc "initialize", "Copy template configuration files"
    def init
      Dir.glob("config/*.template.yml").each do |file|
        template_file = File.basename(file)
        target_file = template_file.sub('.template', '')

        if File.exists?(File.join('config', target_file))
          say "skipping #{target_file.color(:yellow)}, already exists."
        else
          copy_file File.join(CLI.source_root, template_file), File.join(CLI.source_root, target_file)
          say "please edit the #{target_file} to have all the proper configurations"
        end
      end
    end

    desc "export_google_docs SPREADSHEET_NAME WORKSHEET_NAME", "Exports tracking data to google docs"
    long_desc <<-LONGDESC
      Exports all tracking data stored in the db into a google docs.
      e.g. 'tracco export_google_docs tracco_export tracking_data' will export tracking data into a 'tracco_export' sheet,
      in the 'tracking_data' worksheet.
    LONGDESC

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


    desc "version", "Prints Tracco's version information"
    def version
      say "Tracco version #{Tracco::VERSION}"
    end

    desc "ensure_env", "Ensures the environment is valid"
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

    private

    def set_logger_level(verbose)
      Trello.logger.level = verbose ? Logger::DEBUG : Logger::INFO
    end

    def environment_from(options)
      environment = options[:environment]
      error_invalid_environment(environment) unless is_valid_env?(environment)

      return environment
    end

    def date_from(starting_date_as_string)
      if starting_date_as_string == "today"
        Date.today
      else
        parse_date(starting_date_as_string) || error("Invalid date: #{starting_date_as_string}")
      end
    end

    def parse_date(date_as_string)
      Date.parse(date_as_string) rescue nil
    end

    def is_valid_env?(environment)
      %w{production development test}.include? environment
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
