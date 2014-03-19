module TresDelta
  class Customer
    attr_reader :name

    def initialize(params = {})
      @vault_key = params[:vault_key] || nil
      @name      = params[:name] || nil
    end

    def vault_key
      @vault_key ||= SecureRandom.hex(12)
    end

    class << self
      def create(params = {})
        Customer.new(params).tap do |customer|
         unless Vault.new.create_customer(customer).success?
            raise InvalidCustomer
          end
        end
      end
    end

    class InvalidCustomer < Exception; end
  end
end
