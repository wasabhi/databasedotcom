require 'rspec'
require 'spec_helper'
require 'databasedotcom'

Databasedotcom::Chatter::FEED_TYPES.each do |feed_type|
  describe "Databasedotcom::Chatter::#{feed_type}Feed" do
    before do
      @client_mock = double("client", :version => "23")
    end

    describe ".find" do
      before do
        expected_path = feed_type == "Company" ? "/services/data/v23/chatter/feeds/#{feed_type.resourcerize}/feed-items" : "/services/data/v23/chatter/feeds/#{feed_type.resourcerize}/fid/feed-items"
        @client_mock.should_receive(:http_get).with(expected_path).and_return(double "response", :body => {"items" => []}.to_json)
      end

      it "retrieves a #{feed_type}feed" do
        Databasedotcom::Chatter.const_get("#{feed_type}Feed").send(:find, @client_mock, "fid")
      end
    end

    describe ".post" do
      before do
        @client_mock.should_receive(:http_post).with("/services/data/v23/chatter/feeds/#{feed_type.resourcerize}/me/feed-items", nil, { :text => "text" }).and_return(double "response", :body => {"id" => "rid", "name" => "name", "type" => "posted_item", "url" => "some/url"})
      end

      it "posts text passed as a parameter and returns a new FeedItem" do
        result = Databasedotcom::Chatter.const_get("#{feed_type}Feed").send(:post, @client_mock, "me", :text => "text")
        result.should be_instance_of(Databasedotcom::Chatter::FeedItem)
      end
    end

    describe ".post_file" do
      before do
        @client_mock.should_receive(:http_multipart_post).with("/services/data/v23/chatter/feeds/#{feed_type.resourcerize}/me/feed-items", an_instance_of(Hash), an_instance_of(Hash)).and_return(double("response", :body => {"id" => "rid", "name" => "name", "type" => "posted_item", "url" => "some/url"}))
      end

      it "posts the file and returns a new FeedItem" do
        result = Databasedotcom::Chatter.const_get("#{feed_type}Feed").send(:post_file, @client_mock, "me", StringIO.new("foo"), "text/plain", "filename.txt")
        result.should be_instance_of(Databasedotcom::Chatter::FeedItem)
      end
    end
  end
end

