module TresDelta
  class CreditCard
    attr_reader :number, :expiration_month, :expiration_year, :name, :billing_address, :type, :nickname

    attr_accessor :token

    def initialize(params = {})
      @number           = params[:number]
      @expiration_month = params[:expiration_month]
      @expiration_year  = params[:expiration_year]
      @token            = params[:token]
      @name             = params[:name]
      @billing_address  = Address.new(params[:billing_address] || {})
      @type             = params[:type]
      @nickname         = params[:nickname]
    end

    class << self
      def create(customer, params = {})
        CreditCard.new(params).tap do |credit_card|
          add_card = Vault.new.add_stored_credit_card(customer, credit_card)
          raise InvalidCreditCard unless add_card.success?

          credit_card.token = add_card.token
        end
      end
    end
  end

  class InvalidCreditCard < Exception; end
end
