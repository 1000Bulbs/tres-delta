require 'spec_helper'

describe TresDelta::CreditCard do
  let(:customer) { TresDelta::Customer.create(name: "Test Customer") }
  let(:bad_params) do
    {
      number:           '4111111111111111',
      expiration_month: '8',
      expiration_year:  Time.now.strftime("%Y").to_i + 3,
      name:             'Joe Customer',
      type:             'MasterCard',
      nickname:         'Test Visa, Yo.'
    }
  end
  let(:good_params) do
    {
      number:           '4111111111111111',
      expiration_month: '8',
      expiration_year:  Time.now.strftime("%Y").to_i + 3,
      name:             'Joe Customer',
      type:             'Visa',
      nickname:         'Test Visa, Yo.'
    }
  end

  describe "#create" do
    context "successfully saved to vault" do
      it "doesn't raise an exception" do
        expect { TresDelta::CreditCard.create(customer, good_params) }.to_not raise_exception
      end

      let(:credit_card) { TresDelta::CreditCard.create(customer, good_params) }

      it "has a token" do
        expect(credit_card.token).to_not be_nil
      end
    end

    context "fails to save to vault" do
      it "raises an exception" do
        expect { TresDelta::CreditCard.create(customer, bad_params) }.to raise_exception(TresDelta::InvalidCreditCard)
      end
    end
  end
end
