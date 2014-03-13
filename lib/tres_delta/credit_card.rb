module TresDelta
  class CreditCard
    def initialize(params = {})
      @number           = params[:number] || nil
      @expiration_month = params[:expiration_month] || nil
      @expiration_year  = params[:expiration_year] || nil
      @token            = params[:token] || nil
      @name             = params[:name] || nil
      @billing_address  = Address.new(params[:billing_address])
    end
  end
end
