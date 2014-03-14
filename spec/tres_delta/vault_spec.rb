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
end
