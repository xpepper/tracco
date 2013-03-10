module Tracco
  class Environment

    def self.name
      ENV['TRACCO_ENV']
    end

    def self.name=(env_name)
      ENV['TRACCO_ENV'] = env_name.to_s
    end

    def self.test?
      name == "test"
    end

  end
end
