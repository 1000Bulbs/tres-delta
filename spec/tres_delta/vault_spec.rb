require 'spec_helper'

describe TresDelta::Vault do
  let(:config) { TresDelta::Config.config }
  let(:wsdl) { config["management_wsdl"] }

  it "uses the WSDL from the global config" do
    expect(TresDelta::Vault.new.wsdl).to eq(wsdl)
  end

  it "handles storing and retrieving credit card details from ThreeDelta"
end
