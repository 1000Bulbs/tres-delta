require 'savon'

module TresDelta
  class Client
    attr_accessor :wsdl
    attr_accessor :config

    def initialize(wsdl)
      @wsdl = wsdl
    end

    def client_credentials
      {
        "ClientCode" => config["client_code"],
        "Password" => config["password"],
        "UserName" => config["user_name"]
      }
    end

    def client
      @client ||= ::Savon.client wsdl
    end

    def config
      Config.config
    end
  end
end
