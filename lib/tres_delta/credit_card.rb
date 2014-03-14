module TresDelta
  class CreditCard
    attr_reader :number, :expiration_month, :expiration_year, :token, :name, :billing_address, :type, :nickname

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
  end
end
