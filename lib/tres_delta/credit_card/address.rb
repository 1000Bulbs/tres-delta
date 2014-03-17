module TresDelta
  class CreditCard
    class Address
      attr_reader :address, :zip_code

      def initialize(params = {})
        @address  = params[:address]
        @zip_code = params[:zip_code]
      end
    end
  end
end
