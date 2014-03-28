module TresDelta
  class CreditCard
    attr_reader :number, :name, :billing_address, :type, :nickname, :customer, :security_code

    attr_accessor :token, :expiration_month, :expiration_year

    def initialize(params = {})
      @number           = params[:number] || params[:card_account_number]
      @expiration_month = params[:expiration_month]
      @expiration_year  = params[:expiration_year]
      @token            = params[:token]
      @name             = params[:name]
      @billing_address  = Address.new(params[:billing_address] || {})
      @type             = params[:type] || params[:card_type]
      @nickname         = params[:nickname]
      @customer         = params[:customer] || Customer.new
      @security_code    = params[:security_code]
    end

    def save
      if token.nil?
        Vault.add_stored_credit_card(customer, self).success?
      else
        Vault.update_stored_credit_card(customer, self).success?
      end
    end

    def has_security_code?
      security_code.to_s.strip.size > 0
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
