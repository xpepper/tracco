module TrelloConfiguration

  def tracker_username
    @tracker_username ||= ENV["tracker_username"] || configuration["tracker_username"]
  end

  def authorization_params_from_config_file
    configuration["trello"]
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
