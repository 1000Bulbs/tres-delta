module TresDelta
  class Vault < Client
    def initialize
      @wsdl = Config.config['management_wsdl']
    end

    def create_customer(customer)
      request(:create_customer, create_customer_params(customer))
    end

    def create_customer_params(customer)
      {
        'clientCredentials' => client_credentials,
        'createCustomerParams' => {
          'Customer' => {
            'Code' => customer.vault_key,
            'Name' => customer.name
          },
          'LocationIdentifier' => location_identifier
        }
      }
    end
  end
end
