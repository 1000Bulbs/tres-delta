require 'savon'

module TresDelta
  class Client
    attr_accessor :wsdl
    attr_accessor :config

    def initialize(wsdl)
      @wsdl = wsdl
    end

    def request(action, soap_body)
      Response.create_from_action(action, client.call(action, message: soap_body))
    end

    def client_credentials
      {
        "ClientCode" => config["client_code"],
        "Password" => config["password"],
        "UserName" => config["user_name"]
      }
    end

    def location_identifier
      {
        'LocationCode' => config["location_code"],
        'MerchantCode' => config["merchant_code"]
      }
    end

    def client
      @client ||= ::Savon.client(wsdl: wsdl, ssl_version: :SSLv3, ssl_verify_mode: :none, log: false)
    end

    def config
      Config.config
    end
  end
end
