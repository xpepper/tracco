module TrelloConfiguration

  def tracker_username
    @tracker_username ||= ENV["tracker_username"] || configuration["tracker_username"]
  end

  def default_authorization_params
    configuration["trello"]
  end

  private

  def configuration
    @configuration ||= load_configuration
  end

  def load_configuration
    YAML.load_file("config/config.yml")
  end

  def db_environment
    ENV['MONGOID_ENV']
  end

end
