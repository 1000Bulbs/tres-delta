module TresDelta
  class Config
    def self.config=(new_config)
      @@config = new_config
    end

    def self.config
      @@config ||= {}
    end
  end
end
