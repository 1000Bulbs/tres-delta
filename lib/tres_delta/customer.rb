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
  end
end
