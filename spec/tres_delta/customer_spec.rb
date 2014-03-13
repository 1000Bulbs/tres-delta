require 'spec_helper'

describe TresDelta::Customer do
  describe "customer's vault key" do
    context "new customer" do
      let(:customer) { TresDelta::Customer.new }

      it "generates a random vault key" do
        expect(customer.vault_key.size).to eq(24)
      end
    end

    context "existing customer" do
      let(:vault_key) { SecureRandom.hex(12) }
      let(:customer) { TresDelta::Customer.new(vault_key) }

      it "is initialized with a given vault key" do
        expect(customer.vault_key).to eq(vault_key)
      end
    end
  end
end
