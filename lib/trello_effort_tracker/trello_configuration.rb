require 'yaml'

module TrelloConfiguration

  def tracker_username
    @tracker_username ||= ENV["tracker_username"] || configuration["tracker_username"]
  end

  def configuration
    @configuration ||= load_configuration
  end

  private 
  
  def load_configuration
    YAML.load_file("config/config.yml")
  end

end
