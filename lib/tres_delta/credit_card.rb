module TresDelta
  class CreditCard
    attr_reader :number, :expiration_month, :expiration_year, :name, :billing_address, :type, :nickname, :customer

    attr_accessor :token

    def initialize(params = {})
      @number           = params[:number] || params[:card_account_number]
      @expiration_month = params[:expiration_month]
      @expiration_year  = params[:expiration_year]
      @token            = params[:token]
      @name             = params[:name]
      @billing_address  = Address.new(params[:billing_address] || {})
      @type             = params[:type]
      @nickname         = params[:nickname]
      @customer         = params[:customer] || Customer.new
    end

    def save
      if token.nil?
        Vault.add_stored_credit_card(customer, self).success?
      else
        Vault.update_stored_credit_card(customer, self).success?
      end
    end

    class << self
      def create(customer, params = {})
        CreditCard.new(params).tap do |credit_card|
          add_card = Vault.add_stored_credit_card(customer, credit_card)
          raise InvalidCreditCard unless add_card.success?

          credit_card.token = add_card.token
        end
      end

      def find(customer, token, load_number = false)
        stored_card_details = Vault.get_stored_credit_card(customer, token, load_number)
        raise CreditCardNotFound unless stored_card_details.success?

        CreditCard.new(stored_card_details.credit_card.merge(customer: customer))
      end
    end
  end

  class InvalidCreditCard < Exception; end
  class CreditCardNotFound < Exception; end
end
