module TresDelta
  class Gateway < Client
    def initialize
      @wsdl = Config.config['transaction_wsdl']
    end

    def card_verification(transaction_key, credit_card)
      request(:card_verification, card_verification_params(transaction_key, credit_card))
    end

    def card_verification_params(transaction_key, credit_card)
      {
        'clientCredentials'      => client_credentials,
        'cardVerificationParams' => {
          'AddOrUpdateCard' => 'false',
          'CreditCard'      => credit_card_params(credit_card),
          'TerminalIdentifier'   => terminal_identifier,
          'TransactionKey'       => transaction_key
        }
      }
    end

    def credit_card_params(credit_card)
      {
        'BillingAddress'               => billing_address_params(credit_card.billing_address),
        'cc:CardAccountNumber'         => credit_card.number,
        'cc:ExpirationMonth'           => credit_card.expiration_month,
        'cc:ExpirationYear'            => credit_card.expiration_year,
        'NameOnCard'                   => credit_card.name,
        'CardSecurityCode'             => nil,
        'CardSecurityCodeIndicator'    => 'None'
      }
    end

    def billing_address_params(billing_address)
      {
        'PostalCode' => billing_address.zip_code
      }
    end

    def terminal_identifier
      {
        'LocationCode' => config['location_code'],
        'MerchantCode' => config['merchant_code'],
        'TerminalCode' => config['terminal_code']
      }
    end

    def savon_overrides
      { namespaces: { 'xmlns:cc' => 'http://schemas.datacontract.org/2004/07/ThreeDelta.Web.Services.ECLinx.Definitions' } }
    end
  end
end
