require 'spec_helper'

describe TresDelta::Gateway do
  let(:gateway) { TresDelta::Gateway.new }
  let(:transaction_key) { SecureRandom.hex(6) }
  let(:customer) { TresDelta::Customer.new(name: 'FOO BAR') }

  let(:credit_card) do
    TresDelta::CreditCard.new({
      number:           '4242424242424242',
      expiration_month: '03',
      expiration_year:  Time.now.strftime("%Y").to_i + 3,
      name:             'Joe Customer',
      type:             'Visa',
      nickname:         'Test Visa, Yo.',
      billing_address:  address_params
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

  describe "credit card zip code verification" do
    # arbitrary: Cisco, TX
    let(:zip_code_good) { '76437' }

    # magic numbers, see ThreeDelta docs
    let(:zip_code_failure) { '20151' }
    let(:zip_code_unavailable) { '32561' }
    let(:zip_code_error) { '80201' }

    let(:address_params) { { :zip_code => zip_code } }

    let(:response) { gateway.card_verification(transaction_key, credit_card) }

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
    let(:good_address) { "10124 Brentridge Ct" }
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
end
