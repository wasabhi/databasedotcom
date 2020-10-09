require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::SalesForceError do
  context "with a non-array body" do
    before do
      @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/auth_error_response.json"))
      @response_json = Databasedotcom::Utils.emoji_safe_json_parse(@response_body)
      @response = double("result", :body => @response_body)
      @exception = Databasedotcom::SalesForceError.new(@response)
    end

    describe "#message" do
      it "returns the message from the server response" do
        @exception.message.should == @response_json["error_description"]
      end
    end

    describe "#error_code" do
      it "returns the error code from the server response" do
        @exception.error_code.should == @response_json["error"]
      end
    end

    describe "#response" do
      it "returns the HTTPResponse" do
        @exception.response.should == @response
      end
    end
  end

  context "with a array body" do
    before do
      @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/search_error_response.json"))
      @response_json = Databasedotcom::Utils.emoji_safe_json_parse(@response_body)
      @response = double("result", :body => @response_body)
      @exception = Databasedotcom::SalesForceError.new(@response)
    end

    describe "#message" do
      it "returns the message from the server response" do
        @exception.message.should == @response_json[0]["message"]
      end
    end

    describe "#error_code" do
      it "returns the error code from the server response" do
        @exception.error_code.should == @response_json[0]["errorCode"]
      end
    end

    describe "#response" do
      it "returns the HTTPResponse" do
        @exception.response.should == @response
      end
    end
  end
end
