require 'spec_helper'

describe TresDelta::Vault do
  let(:config) { TresDelta::Config.config }
  let(:wsdl) { config["management_wsdl"] }
  let(:customer) { TresDelta::Customer.new(name: name) }
  let(:name) { SecureRandom.hex(4) }
  let(:vault) { TresDelta::Vault.new }

  it "uses the WSDL from the global config" do
    expect(vault.wsdl).to eq(wsdl)
  end

  describe ".create_customer" do
    let!(:response) { vault.create_customer(customer) }

    it "is successful" do
      expect(response.success?).to be_true
    end

    context "try to create a customer again" do
      it "fails horribly" do
        repeat_response = vault.create_customer(customer)
        expect(repeat_response.success?).to be_false
      end
    end
  end

  describe ".add_stored_credit_card" do
    let(:customer) { TresDelta::Customer.new(name: 'Test Customer') }
    let(:vault) { TresDelta::Vault.new }
    let(:good_visa) do
      TresDelta::CreditCard.new({
        number:           '4111111111111111',
        expiration_month: '8',
        expiration_year:  Time.now.strftime("%Y").to_i + 3,
        name:             'Joe Customer',
        type:             'Visa',
        nickname:         'Test Visa, Yo.'
      })
    end

    before(:each) do
      vault.create_customer(customer)
    end

    context "a good credit card" do
      let(:response) { vault.add_stored_credit_card(customer, good_visa) }

      it "saves the damn credit card" do
        response.success?.should be_true
      end

      it "has a token" do
        expect(response.token).to_not be_nil
      end
    end

    context "a duplicate credit card" do
      let!(:first_response) { vault.add_stored_credit_card(customer, good_visa) }
      let(:response) { vault.add_stored_credit_card(customer, good_visa) }

      it "fails to save the card probably" do
        expect(response.success?).to be_false
      end

      it "has a card number in use failure reason" do
        expect(response.failure_reason).to eq(TresDelta::Errors::CARD_NUMBER_IN_USE)
      end
    end
  end
end
