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

  class Database
    def self.load_env(tracco_env, mongoid_configuration_path=nil)
      Tracco::Environment.name = tracco_env
      Mongoid.load!(mongoid_configuration_path || "config/mongoid.yml", tracco_env)
      Trello.logger.info "Mongo db env: #{tracco_env.color(:green)}."
    end
  end

  private

  def configuration
    @configuration ||= load_configuration
  end

  def load_configuration
    YAML.load_file("config/config.yml")
  end

end
