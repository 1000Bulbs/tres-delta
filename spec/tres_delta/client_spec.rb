require 'spec_helper'

describe TresDelta::Client do
  let(:wsdl) { "http://example.com" }
  let(:config) do
    {
      "client_code" => "1000Bulbs",
      "password"    => "secrets",
      "user_name"   => "some_dude"
    }
  end

  let(:client) { TresDelta::Client.new(wsdl) }

  describe "#client_credentials" do
    before(:each) do
      TresDelta::Config.config = config
    end

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
      client.client.wsdl.document.should == wsdl
    end
  end
end
