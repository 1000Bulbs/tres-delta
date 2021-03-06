require 'savon'

module TresDelta
  class Client
    class << self
      attr_accessor :wsdl

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
        # TODO: Make this configurable via file. Because right now this ain't secure. -_-
        @client ||= ::Savon.client(savon_options)
      end

      def savon_options
        default_savon_options.merge(savon_overrides || {})
      end

      def default_savon_options
        { wsdl: wsdl, ssl_verify_mode: :none, log: false, open_timeout: 120, read_timeout: 120 }
      end

      def savon_overrides; end

      def config
        Config.config
      end
    end
  end
end
