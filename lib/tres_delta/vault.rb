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

    def add_stored_credit_card(customer, credit_card)
      request(:add_stored_credit_card, add_stored_credit_card_params(customer, credit_card))
    end

    def add_stored_credit_card_params(customer, credit_card)
      {
        'clientCredentials'   => client_credentials,
        'addStoredCardParams' => {
          'CreditCard' => {
            'CardAccountNumber' => credit_card.number,
            'CardType'          => credit_card.type,
            'Cardholder'        => {
              'FirstName' => credit_card.name,
              'LastName'  => nil
            },
            'ExpirationMonth'   => credit_card.expiration_month,
            'ExpirationYear'    => credit_card.expiration_year,
            'NameOnCard'        => credit_card.name,
            'FriendlyName'      => credit_card.nickname
          },
          'CustomerIdentifier' => customer_identifier(customer)
        }
      }
    end

    def customer_identifier(customer)
      {
        'CustomerCode' => customer.vault_key,
        'LocationCode' => config["location_code"],
        'MerchantCode' => config["merchant_code"]
      }
    end

    def get_stored_credit_card(customer, token, include_card_number = false)
      request(:get_stored_credit_card, get_stored_credit_card_params(customer, token, include_card_number))
    end

    def get_stored_credit_card_params(customer, token, include_card_number)
      {
        'clientCredentials'         => client_credentials,
        'getStoredCreditCardParams' => {
          'CustomerIdentifier' => customer_identifier(customer),
          'RetrieveCardNumber' => include_card_number ? 'true' : 'false',
          'Token' => token
        }
      }
    end

    def get_token_for_card_number(card_number, customer)
      request(:get_token_for_card_number, get_token_for_card_number_params(card_number, customer))
    end

    def get_token_for_card_number_params(card_number, customer)
      {
        'clientCredentials'           => client_credentials,
        'getTokenForCardNumberParams' => {
          'AccountNumber'      => card_number,
          'CustomerIdentifier' => customer_identifier(customer)
        }
      }
    end

    def update_stored_credit_card(customer, credit_card)
      request(:update_stored_credit_card, update_stored_credit_card_params(customer, credit_card))
    end

    def update_stored_credit_card_params(customer, credit_card)
      {
        'clientCredentials'      => client_credentials,
        'updateStoredCardParams' => {
          'CreditCard' => {
            'CardType' => credit_card.type,
            'CardHolder' => {
              'FirstName' => credit_card.name,
              'Lastname'  => nil
            },
            'ExpirationMonth' => credit_card.expiration_month,
            'ExpirationYear'  => credit_card.expiration_year,
            'NameOnCard'      => credit_card.name,
            'FriendlyName'    => credit_card.nickname,
            'Token'           => credit_card.token
          },
          'CustomerIdentifier'     => customer_identifier(customer)
        }
      }
    end
  end
end
