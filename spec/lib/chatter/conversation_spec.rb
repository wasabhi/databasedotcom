require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Chatter::Conversation do
  it_should_behave_like("a restful resource")

  describe ".archive" do
    before do
      @client_mock = double("client", :version => 23)
    end

    it "archives the conversation" do
      response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/conversations_get_id_success_response.json")))
      @client_mock.should_receive(:http_patch).with("/services/data/v23/chatter/users/me/conversations/cid", nil, :archived => "true").and_return(response)
      Databasedotcom::Chatter::Conversation.archive(@client_mock, "cid").should be_instance_of(Databasedotcom::Chatter::Conversation)
    end
  end

  describe ".unarchive" do
    before do
      @client_mock = double("client", :version => 23)
    end

    it "unarchives the conversation" do
      response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/conversations_get_id_success_response.json")))
      @client_mock.should_receive(:http_patch).with("/services/data/v23/chatter/users/me/conversations/cid", nil, :archived => "false").and_return(response)
      Databasedotcom::Chatter::Conversation.unarchive(@client_mock, "cid").should be_instance_of(Databasedotcom::Chatter::Conversation)
    end
  end

  describe ".mark_read" do
    before do
      @client_mock = double("client", :version => 23)
    end

    it "marks the conversation as read" do
      response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/conversations_get_id_success_response.json")))
      @client_mock.should_receive(:http_patch).with("/services/data/v23/chatter/users/me/conversations/cid", nil, :read => "true").and_return(response)
      Databasedotcom::Chatter::Conversation.mark_read(@client_mock, "cid").should be_instance_of(Databasedotcom::Chatter::Conversation)
    end
  end

  describe ".mark_unread" do
    before do
      @client_mock = double("client", :version => 23)
    end

    it "marks the conversation as unread" do
      response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/conversations_get_id_success_response.json")))
      @client_mock.should_receive(:http_patch).with("/services/data/v23/chatter/users/me/conversations/cid", nil, :read => "false").and_return(response)
      Databasedotcom::Chatter::Conversation.mark_unread(@client_mock, "cid").should be_instance_of(Databasedotcom::Chatter::Conversation)
    end
  end

  describe ".messages" do
    before do
      @client_mock = double("client", :version => 23)
    end

    it "gets the messages for the conversation" do
      response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/conversations_get_id_success_response.json")))
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/uid/conversations/cid", an_instance_of(Hash)).and_return(response)
      messages = Databasedotcom::Chatter::Conversation.messages(@client_mock, "uid", "cid")
      messages.should be_instance_of(Databasedotcom::Collection)
      messages.each do |message|
        message.should be_instance_of(Databasedotcom::Chatter::Message)
      end
    end
  end

  context "with a Conversation object" do
    before do
      @client_mock = double("client", :version => 23)
      @conversation = Databasedotcom::Chatter::Conversation.new(@client_mock, File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/conversations_get_id_success_response.json")))
    end

    describe "#initialize" do
      it "initializes id and url" do
        @conversation.id.should == @conversation.raw_hash["conversationId"]
        @conversation.url.should == @conversation.raw_hash["conversationUrl"]
      end
    end

    describe "#archive" do
      it "archives the conversation" do
        Databasedotcom::Chatter::Conversation.should_receive(:archive).with(@client_mock, @conversation.id)
        @conversation.archive
      end
    end

    describe "#unarchive" do
      it "unarchives the conversation" do
        Databasedotcom::Chatter::Conversation.should_receive(:unarchive).with(@client_mock, @conversation.id)
        @conversation.unarchive
      end
    end

    describe "#mark_read" do
      it "marks the conversation as read" do
        Databasedotcom::Chatter::Conversation.should_receive(:mark_read).with(@client_mock, @conversation.id)
        @conversation.mark_read
      end
    end

    describe "#mark_unread" do
      it "marks the conversation unread" do
        Databasedotcom::Chatter::Conversation.should_receive(:mark_unread).with(@client_mock, @conversation.id)
        @conversation.mark_unread
      end
    end

    describe "#messages" do
      it "gets the messages for the conversation" do
        messages = @conversation.messages
        messages.should be_an_instance_of(Databasedotcom::Collection)
        messages.each do |message|
          message.should be_an_instance_of(Databasedotcom::Chatter::Message)
        end
      end
    end
  end
end