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
      puts e.message
      puts "try running 'rake prepare'"
    end
  end

  class Database
    def self.load_env(tracco_env, mongoid_configuration_path=nil)
      Tracco.environment = tracco_env
      Mongoid.load!(mongoid_configuration_path || "config/mongoid.yml", tracco_env)
      Trello.logger.debug "Mongo db env: #{tracco_env.color(:green)}."
    end
  end

end
