module TresDelta
  class Customer
    def initialize(vault_key = nil)
      @vault_key = vault_key
    end

    def vault_key
      @vault_key ||= SecureRandom.hex(12)
    end
  end
end
