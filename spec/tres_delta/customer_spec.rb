require 'spec_helper'

describe TresDelta::Customer do
  describe "initalization" do
    let(:name) { "Johnny B" }

    context "new customer" do
      let(:customer) { TresDelta::Customer.new(:name => name) }

      it "generates a random vault key" do
        expect(customer.vault_key.size).to eq(24)
      end

      it "uses the assigned name" do
        expect(customer.name).to eq(name)
      end
    end

    context "existing customer" do
      let(:vault_key) { SecureRandom.hex(12) }
      let(:customer) { TresDelta::Customer.new(:vault_key => vault_key) }

      it "is initialized with a given vault key" do
        expect(customer.vault_key).to eq(vault_key)
      end
    end
  end

  describe "#create" do
    let(:customer) { TresDelta::Customer.create(customer_data) }

    context "good customer info" do
      let(:vault_key) { SecureRandom.hex(6) }
      let(:customer_data) { { name: "Joe Tester", vault_key: vault_key } }

      it "creates the customer" do
        expect(customer).to be_a(TresDelta::Customer)
      end

      it "has the initialized values" do
        expect(customer.vault_key).to eq(vault_key)
        expect(customer.name).to eq(customer_data[:name])
      end
    end

    context "bad customer info" do
      let(:customer_data) { Hash.new }

      it "raises an error" do
        expect { customer }.to raise_exception(TresDelta::Customer::InvalidCustomer)
      end
    end
  end
end
