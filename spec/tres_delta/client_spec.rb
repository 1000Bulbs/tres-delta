require 'spec_helper'

describe TresDelta::Client do
  let(:wsdl) { "http://example.com" }

  let(:client) { TresDelta::Client.new(wsdl) }
  let(:config) { TresDelta::Config.config }

  describe "#client_credentials" do
    it "uses the credentials passed into it" do
      client.client_credentials.should == {
        "ClientCode" => config["client_code"],
        "Password" => config["password"],
        "UserName" => config["user_name"]
      }
    end
  end

  describe "#client" do
    it "returns a Savon client for the WSDL" do
      client.client.class.should == Savon::Client
    end
  end
end
