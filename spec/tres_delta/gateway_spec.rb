require 'spec_helper'

describe TresDelta::Gateway do
  let(:gateway) { TresDelta::Gateway }
  let(:transaction_key) { SecureRandom.hex(6) }
  let(:customer) { TresDelta::Customer.new(name: 'FOO BAR') }
  let(:good_address) { "10124 Brentridge Ct" }
  let(:security_code) { nil }
  let(:address) { good_address }
  let(:address_params) { { :address => address } }

  # arbitrary: Cisco, TX
  let(:zip_code_good) { '76437' }

  let(:credit_card) do
    TresDelta::CreditCard.new({
      number:           '4242424242424242',
      expiration_month: '03',
      expiration_year:  Time.now.strftime("%Y").to_i + 3,
      name:             'Joe Customer',
      type:             'Visa',
      nickname:         'Test Visa, Yo.',
      billing_address:  address_params,
      security_code:    security_code
    })
  end

  it "has a goddamn wsdl" do
    expect(gateway.wsdl).to eq(TresDelta::Config.config['transaction_wsdl'])
  end

  describe "credit card address verification" do
    context "full credit card information" do
    end

    context "with a token" do
    end
  end

  describe "#credit_card_params" do
    subject(:params) { gateway.credit_card_params(credit_card) }

    it "should include the card number" do
      expect(params['cc:CardAccountNumber']).to eq('4242424242424242')
    end

    it "should include the name on the card" do
      expect(params['cc:NameOnCard']).to eq('Joe Customer')
    end
  end

  describe "credit card zip code verification" do

    # magic numbers, see ThreeDelta docs
    let(:zip_code_failure) { '20151' }
    let(:zip_code_unavailable) { '32561' }
    let(:zip_code_error) { '80201' }

    let(:address_params) { { :zip_code => zip_code } }

    let(:response) { gateway.card_verification(transaction_key, credit_card) }

    context "checking card security code" do
      let(:zip_code) { zip_code_good }
      subject { response.card_security_code_response }

      context "no security code provided" do
        it { should eq('None') }
      end

      context "security code is empty string" do
        let(:security_code) { "" }

        it { should eq('None') }
        it "should respond true" do
          expect(response.success?).to be_true
        end
      end

      context "security code provided" do
        context "invalid security code" do
          let(:security_code) { 123 } # fails in development mode

          it { should eq('NotMatched') }
        end

        context "valid security code" do
          let(:security_code) { 666 }

          it { should eq('Matched') }
        end
      end
    end

    context "good zip code" do
      let(:zip_code) { zip_code_good }

      it "passes aip code avs" do
        expect(response.success?).to be_true
      end
    end

    context "zip code failure" do
      let(:zip_code) { zip_code_failure }

      it "fails the zip code avs" do
        expect(response.success?).to be_true
        expect(response.postal_code_avs_response).to eq("NotMatched")
      end
    end

    context "zip code unavailable" do
      let(:zip_code) { zip_code_unavailable }

      it "doesn't really fail the avs check" do
        expect(response.success?).to be_true
        expect(response.postal_code_avs_response).to eq("Unavailable")
      end
    end

    context "zip code avs error" do
      let(:zip_code) { zip_code_error }

      it "doesn't fail per se" do
        expect(response.success?).to be_true
        expect(response.postal_code_avs_response).to eq("Error")
      end
    end
  end

  describe "credit card address verificaiton" do
    let(:bad_address) { "14151 Brentridge Ct" }
    let(:address_params) { { :address => address } }

    let(:response) { gateway.card_verification(transaction_key, credit_card) }

    context "good address" do
      let(:address) { good_address }

      it "passes avs" do
        expect(response.success?).to be_true
        expect(response.address_avs_response).to eq('Matched')
      end
    end

    context "bad address" do
      let(:address) { bad_address }

      it "fails avs" do
        expect(response.success?).to be_true
        expect(response.address_avs_response).to eq('NotMatched')
      end
    end
  end

  describe "authorize" do
    let(:order_number) { SecureRandom.hex(6) }
    let(:amount) { 13.37 }
    let(:address_params) { { address: good_address, zip_code: zip_code_good} }
    let(:response) { gateway.authorize(transaction_key, credit_card, amount, order_number, customer) }
    let(:vault) { TresDelta::Vault }

    before(:each) do
      vault.create_customer(customer)
    end

    context "good transaction" do
      it "is successful" do
        expect(response.success?).to be_true
      end
    end

    context "card declined" do
      let(:amount) { "0.20" } # see 3Delta docs

      it "isn't successful" do
        expect(response.success?).to be_false
      end
    end

    context "bad expiration" do
      let(:amount) { "0.29" } # see 3Delta docs

      it "isn't successful" do
        expect(response.success?).to be_false
        expect(response.credit_card_response_status).to eq('ExpirationDateIncorrect')
      end
    end
  end
end
