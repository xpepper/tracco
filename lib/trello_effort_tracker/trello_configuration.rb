module TrelloConfiguration

  def tracker_username
    @tracker_username ||= ENV["tracker_username"] || configuration["tracker_username"]
  end

  def authorization_params_from_config_file
    configuration["trello"]
  end

  class Database
    def self.load_env(db_env)
      ENV['MONGOID_ENV'] = db_env
      Mongoid.load!("config/mongoid.yml", db_env)
    end
  end

  private

  def db_environment
    ENV['MONGOID_ENV']
  end

  def configuration
    @configuration ||= load_configuration
  end

  def load_configuration
    YAML.load_file("config/config.yml")
  end

end
