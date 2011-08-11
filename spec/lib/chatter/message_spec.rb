require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Chatter::Message do
  it_should_behave_like("a restful resource")

  describe ".send_message" do
    before do
      @client_mock = double("client", :version => "23")
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/messages_get_id_success_response.json")))
    end

    it "sends a private message" do
      @client_mock.should_receive(:http_post).with("/services/data/v23/chatter/users/me/messages", nil, :recipients => "rid", :text => "text").and_return(@response)
      Databasedotcom::Chatter::Message.send_message(@client_mock, "rid", "text").should be_instance_of(Databasedotcom::Chatter::Message)
    end

    it "supports multiple recipients" do
      @client_mock.should_receive(:http_post).with("/services/data/v23/chatter/users/me/messages", nil, :recipients => "rid1,rid2", :text => "text").and_return(@response)
      Databasedotcom::Chatter::Message.send_message(@client_mock, %w(rid1 rid2), "text").should be_instance_of(Databasedotcom::Chatter::Message)
    end
  end

  describe ".reply" do
    before do
      @client_mock = double("client", :version => "23")
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/messages_get_id_success_response.json")))
    end

    it "replies to a private message" do
      @client_mock.should_receive(:http_post).with("/services/data/v23/chatter/users/me/messages", nil, :inReplyTo => "mid", :text => "text").and_return(@response)
      Databasedotcom::Chatter::Message.reply(@client_mock, "mid", "text").should be_instance_of(Databasedotcom::Chatter::Message)
    end
  end

  context "with an instantiated Message" do
    before do
      msg = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/messages_get_id_success_response.json"))
      @client_mock = double("client", :version => "23")
      @response = double("response")
      @message = Databasedotcom::Chatter::Message.new(@client_mock, msg)
    end

    describe "#reply" do
      it "replies to a message" do
        Databasedotcom::Chatter::Message.should_receive(:reply).with(@client_mock, @message.id, "text")
        @message.reply("text")
      end
    end
  end
end