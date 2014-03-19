require 'spec_helper'

describe TresDelta::Vault do
  let(:config) { TresDelta::Config.config }
  let(:wsdl) { config["management_wsdl"] }
  let(:customer) { TresDelta::Customer.new(name: name) }
  let(:name) { SecureRandom.hex(4) }
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

    context "bad type" do
      let(:bad_visa) do
        TresDelta::CreditCard.new({
          number:           '4111111111111111',
          expiration_month: '8',
          expiration_year:  Time.now.strftime("%Y").to_i + 3,
          name:             'Joe Customer',
          type:             'MasterCard',
          nickname:         'Test Visa, Yo.'
        })
      end

      let(:response) { vault.add_stored_credit_card(customer, bad_visa) }

      it "doesn't save the card" do
        expect(response.success?).to be_false
      end

      it "has validation errors" do
        expect(response.validation_failures.size).to be  > 0
      end

      it "has a failure reason" do
        expect(response.failure_reason).to eq(TresDelta::Errors::VALIDATION_FAILED)
      end
    end
  end

  describe "get_stored_credit_card", :focus => true do
    let(:include_card_number) { false }
    let(:response) { vault.get_stored_credit_card(customer, token, include_card_number) }

    before(:each) do
      vault.create_customer(customer)
    end

    context "card doesn't exist" do
      let(:token) { SecureRandom.hex(6) } # random, lol

      it "fails" do
        expect(response.success?).to be_false
        expect(response.failure_reason).to eq('CreditCardDoesNotExist')
      end
    end

    context "card exists" do
      let(:token) { vault.add_stored_credit_card(customer, good_visa).token }
      let(:card_data) { response.credit_card }

      context "card number not included" do
        it "is successful" do
          expect(response.success?).to be_true
        end

        it "contains the details of the credit card" do
          expect(card_data[:expiration_month]).to eq(good_visa.expiration_month.to_s)
          expect(card_data[:expiration_year]).to eq(good_visa.expiration_year.to_s)
          expect(card_data[:name_on_card]).to eq(good_visa.name)
          expect(card_data[:friendly_name]).to eq(good_visa.nickname)
          expect(card_data[:token]).to eq(token)
        end

        it "doesn't contain the credit card number" do
          expect(card_data[:card_account_number]).to be_nil
        end
      end

      context "card number included" do
        let(:include_card_number) { true }

        it "is successful" do
          expect(response.success?).to be_true
        end

        it "contains the credit card number" do
          expect(card_data[:card_account_number]).to eq(good_visa.number)
        end
      end
    end
  end

  describe "get_token_for_card_number" do
    let(:response) { vault.get_token_for_card_number(card_number, customer) }

    context "credit card doesn't exist" do
      let(:card_number) { '4111111111111111' }

      it "isn't successful" do
        expect(response.success?).to be_false
      end
    end

    context "credit card does exist" do
      let(:card_number) { good_visa.number }

      let!(:token) { vault.create_customer(customer); vault.add_stored_credit_card(customer, good_visa).token }

      it "is successful" do
        expect(response.success?).to be_true
      end

      it "has the card's token" do
        expect(response.token).to eq(token)
      end
    end
  end
end
