require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Chatter::FeedItem do
  it_should_behave_like("a restful resource")

  context "with a FeedItem object" do
    before do
      @response = Databasedotcom::Utils.emoji_safe_json_parse(File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/feed-items_get_id_success_response.json")))
      @client_mock = double("client", :version => "23")
      @record = Databasedotcom::Chatter::FeedItem.new(@client_mock, @response)
    end

    describe "#comments" do
      it "returns a collection of comment records" do
        @record.comments.should be_instance_of(Databasedotcom::Collection)
      end
    end

    describe "#likes" do
      it "returns a collection of like records" do
        @record.likes.should be_instance_of(Databasedotcom::Collection)
      end
    end

    describe "#like" do
      it "likes the feed item" do
        body = Databasedotcom::Utils.emoji_safe_json_parse(File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/likes_get_id_success_response.json")))
        @response = double("response")
        @response.should_receive(:body).any_number_of_times.and_return(body)
        @client_mock.should_receive(:http_post).with("/services/data/v23/chatter/feed-items/#{@record.id}/likes").and_return(@response)
        like = @record.like
        like.should be_instance_of(Databasedotcom::Chatter::Like)
      end
    end

    describe "#comment" do
      it "comments on the feed item" do
        body = Databasedotcom::Utils.emoji_safe_json_parse(File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/comments_get_id_success_response.json")))
        @response = double("response")
        @response.should_receive(:body).any_number_of_times.and_return(body)
        @client_mock.should_receive(:http_post).with("/services/data/v23/chatter/feed-items/#{@record.id}/comments", nil, :text => "whatever").and_return(@response)
        comment = @record.comment("whatever")
        comment.should be_instance_of(Databasedotcom::Chatter::Comment)
      end
    end
  end
end