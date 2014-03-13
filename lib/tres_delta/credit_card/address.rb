module TresDelta
  class CreditCard
    class Address
      def initialize(params = {})
        @zip_code = params[:zip_code]
      end
    end
  end
end
