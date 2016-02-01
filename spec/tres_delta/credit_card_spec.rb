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
      nickname:         'Test Visa, Yo.',
      customer:         customer
    }
  end

  let(:good_params) do
    {
      number:           '4111111111111111',
      expiration_month: '8',
      expiration_year:  Time.now.strftime("%Y").to_i + 3,
      name:             'Joe Customer',
      type:             'Visa',
      nickname:         'Test Visa, Yo.',
      customer:         customer
    }
  end

  let(:credit_card) { TresDelta::CreditCard.create(customer, good_params) }

  describe "#create" do
    context "successfully saved to vault" do
      it "doesn't raise an exception" do
        expect { TresDelta::CreditCard.create(customer, good_params) }.to_not raise_exception
      end

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

  describe "#find" do
    context "card exists" do
      let(:token) { credit_card.token }
      let(:found_card) { TresDelta::CreditCard.find(customer, token, true) }

      it "returns a credit card object" do
        expect(found_card).to be_a(TresDelta::CreditCard)
        expect(found_card.number).to eq(credit_card.number)
        expect(found_card.token).to eq(token)
        expect(found_card.expiration_month).to eq(credit_card.expiration_month)
        expect(found_card.expiration_year.to_i).to eq(credit_card.expiration_year)
        expect(found_card.customer).to eq(customer)
        expect(found_card.type).to eq(credit_card.type)
      end
    end

    context "not found" do
      let(:token) { SecureRandom.hex(6) }

      it "raises an error" do
        expect { TresDelta::CreditCard.find(customer, token) }.to raise_exception(TresDelta::CreditCardNotFound)
      end
    end
  end

  describe ".save" do
    let(:credit_card) { TresDelta::CreditCard.new(params) }
    let(:result) { credit_card.save }
    context "card hasn't been tokenized" do
      context "bad data" do
        let(:params) { bad_params }

        it "returns false" do
          expect(result).to be_falsey
        end
      end

      context "good data" do
        let(:params) { good_params }

        it "returns true" do
          expect(result).to be_truthy
        end
      end
    end

    context "card has been tokenized" do
      let(:token) { TresDelta::CreditCard.create(customer, good_params).token }

      context "good data" do
        let(:params) { good_params.merge(:token => token) }

        it "returns true" do
          expect(result).to be_truthy
        end
      end

      context "bad data" do
        let(:params) { bad_params.merge(:token => token, :expiration_month => 13) }

        it "returns false" do
          expect(result).to be_falsey
        end
      end
    end
  end

  describe ".has_security_code" do
    let(:credit_card) { TresDelta::CreditCard.new(security_code: security_code) }
    subject { credit_card.has_security_code? }

    context "code is nil" do
      let(:security_code) { nil }
      it { is_expected.to be_falsey }
    end

    context "code is empty string" do
      let(:security_code) { "" }
      it { is_expected.to be_falsey }
    end

    context "code is blank string" do
      let(:security_code) { " " }
      it { is_expected.to be_falsey }
    end

    context "code is set" do
      let(:security_code) { "123" }
      it { is_expected.to be_truthy }
    end
  end
end
