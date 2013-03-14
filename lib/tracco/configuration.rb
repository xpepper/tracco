require 'yaml'

module Tracco
  def self.environment
    ENV['TRACCO_ENV']
  end

  def self.environment=(env_name)
    ENV['TRACCO_ENV'] = env_name.to_s
  end

  def self.load_env!
    begin
      Database.load_env(environment || "development", ENV['MONGOID_CONFIG_PATH'])
    rescue Errno::ENOENT => e
      Trello.logger.warn e.message
      Trello.logger.warn "try running 'rake prepare'"
    end
  end

  class Database
    def self.load_env(tracco_env, mongoid_configuration_path=nil)
      Tracco.environment = tracco_env
      Mongoid.load!(mongoid_configuration_path || "config/mongoid.yml", tracco_env)
      Trello.logger.debug "Mongo db env: #{tracco_env.color(:green)}."
    end
  end

  module TrelloConfiguration

    def tracker_username(forced_tracker_username=nil)
      @tracker_username ||= forced_tracker_username || ENV["tracker_username"] || configuration["tracker_username"]
    end

    def authorization_params_from_config_file
      begin
        configuration["trello"]
      rescue NoMethodError => e
        Trello.logger.info "Invalid configuration file".color(:red)
        {}
      end
    end

    private

    def configuration
      @configuration ||= YAML.load_file("config/config.yml")
    end
  end

end
