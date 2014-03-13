require 'savon'

module TresDelta
  class Client
    attr_accessor :wsdl
    attr_accessor :config

    def initialize(wsdl, config)
      @wsdl   = wsdl
      @config = config
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
  end
end
