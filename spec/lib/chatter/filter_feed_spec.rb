require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Chatter::FilterFeed do
  describe ".feeds" do
    before do
      @response = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/filter_feed_get_all_success_response.json"))
      @client_mock = double("client", :version => "23")
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/feeds/filter/uid").and_return(double("response", :body => @response))
    end

    it "returns a hash describing the filter feeds" do
      Databasedotcom::Chatter::FilterFeed.feeds(@client_mock, "uid").should be_instance_of(Hash)
    end
  end
end