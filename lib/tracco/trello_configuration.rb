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
    @configuration ||= load_configuration
  end

  def load_configuration
    YAML.load_file("config/config.yml")
  end

end
