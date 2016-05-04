module TresDelta
  class Gateway < Client

    class << self
      def wsdl
        Config.config['transaction_wsdl']
      end

      def authorize(transaction_key, credit_card, amount, order_number, customer)
        request :authorize, authorize_params(transaction_key, credit_card, amount, order_number, customer)
      end

      def authorize_params(transaction_key, credit_card, amount, order_number, customer)
        {
          'clientCredentials' => client_credentials,
          'authorizeParams'   => {
            'AddOrUpdateCard'       => 'true',
            'CreditCardTransaction' => {
              'CreditCard'   => credit_card_params(credit_card),
              'CurrencyCode' => 'USDollars',
              'StoredCardIdentifier' => {
                'CustomerCode' => customer.vault_key
              },
              'TotalAmount' => amount,
              'TransactionKey' => transaction_key
            },
            'TerminalIdentifier' => terminal_identifier
          }
        }
      end

      def capture(transaction_key, customer_code, card_token, amount)
        request :capture, capture_params(transaction_key, customer_code, card_token, amount)
      end

      def capture_params(transaction_key, customer_code, card_token, amount)
        {
          'clientCredentials' => client_credentials,
          'captureParams'     => {
            'CreditCardTransaction' => {
              'CurrencyCode'         => 'USDollars',
              'StoredCardIdentifier' => {
                'CustomerCode' => customer_code,
                'Token'        => card_token
              },
              'TotalAmount' => amount,
              'TransactionKey' => transaction_key
            },
            'TerminalIdentifier'    => terminal_identifier
          }
        }
      end

      def card_verification(transaction_key, credit_card)
        request(:card_verification, card_verification_params(transaction_key, credit_card))
      end

      def card_verification_params(transaction_key, credit_card)
        {
          'clientCredentials'      => client_credentials,
          'cardVerificationParams' => {
            'AddOrUpdateCard'      => 'false',
            'CreditCard'           => credit_card_params(credit_card),
            'TerminalIdentifier'   => terminal_identifier,
            'TransactionKey'       => transaction_key
          }
        }
      end

      def credit_card_params(credit_card)
        {
          'cc:BillingAddress'            => billing_address_params(credit_card.billing_address),
          'cc:CardAccountNumber'         => credit_card.number,
          'cc:ExpirationMonth'           => credit_card.expiration_month,
          'cc:ExpirationYear'            => credit_card.expiration_year,
          'cc:NameOnCard'                => credit_card.name,
          'CardSecurityCode'             => credit_card.security_code,
          'CardSecurityCodeIndicator'    => credit_card.has_security_code? ? 'Provided' : 'None'
        }
      end

      def billing_address_params(billing_address)
        {
          'cc:AddressLine1' => billing_address.address,
          'cc:PostalCode'   => billing_address.zip_code
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
        {
          namespaces: {
            'xmlns:cc' => 'http://schemas.datacontract.org/2004/07/ThreeDelta.Web.Services.ECLinx.Definitions'
          }
        }
      end
    end
  end
end
