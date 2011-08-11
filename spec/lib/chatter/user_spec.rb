require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Chatter::User do
  it_should_behave_like("a restful resource")
  it_should_behave_like("a resource with a photo")

  describe ".followers" do
    before do
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/users_followers_get_id_success_response.json")))
      @client_mock = double("client", :version => "23")
    end

    it "returns a collection of followers subscriptions for a user" do
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/foo/followers").and_return(@response)
      followers = Databasedotcom::Chatter::User.followers(@client_mock, "foo")
      followers.should be_instance_of(Databasedotcom::Collection)
      followers.each do |follower|
        follower.should be_instance_of(Databasedotcom::Chatter::Subscription)
      end
    end

    it "defaults user id to 'me'" do
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/me/followers").and_return(@response)
      Databasedotcom::Chatter::User.followers(@client_mock)
    end
  end

  describe ".following" do
    before do
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/users_following_get_id_success_response.json")))
      @client_mock = double("client", :version => "23")
    end

    it "returns a collection of following subscriptions for a user" do
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/foo/following").and_return(@response)
      followings = Databasedotcom::Chatter::User.following(@client_mock, "foo")
      followings.should be_instance_of(Databasedotcom::Collection)
      followings.each do |following|
        following.should be_instance_of(Databasedotcom::Chatter::Subscription)
      end
    end

    it "defaults user id to 'me'" do
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/me/following").and_return(@response)
      Databasedotcom::Chatter::User.following(@client_mock)
    end
  end

  describe ".follow" do
    before do
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/subscriptions_get_id_success_response.json")))
      @client_mock = double("client", :version => "23")
    end

    it "follows the record specified by id and returns a new subscription" do
      @client_mock.should_receive(:http_post).with("/services/data/v23/chatter/users/me/following", nil, :subjectId => "rid").and_return(@response)
      Databasedotcom::Chatter::User.follow(@client_mock, "me", "rid").should be_instance_of(Databasedotcom::Chatter::Subscription)
    end
  end

  describe ".groups" do
    before do
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/users_groups_get_id_success_response.json")))
      @client_mock = double("client", :version => "23")
    end

    it "returns a collection of following subscriptions for a user" do
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/foo/groups").and_return(@response)
      groups = Databasedotcom::Chatter::User.groups(@client_mock, "foo")
      groups.should be_instance_of(Databasedotcom::Collection)
      groups.each do |group|
        group.should be_instance_of(Databasedotcom::Chatter::Group)
      end
    end

    it "defaults user id to 'me'" do
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/me/groups").and_return(@response)
      Databasedotcom::Chatter::User.groups(@client_mock)
    end
  end

  describe ".status" do
    before do
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/users_status_get_id_success_response.json")))
      @client_mock = double("client", :version => "23")
    end

    it "returns a hash containing status info" do
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/foo/status").and_return(@response)
      groups = Databasedotcom::Chatter::User.status(@client_mock, "foo")
      groups.should be_instance_of(Hash)
    end

    it "defaults user id to 'me'" do
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/me/status").and_return(@response)
      Databasedotcom::Chatter::User.status(@client_mock)
    end
  end

  describe ".delete_status" do
    before do
      @client_mock = double("client", :version => "23")
    end

    it "deletes the status of the specified user" do
      @client_mock.should_receive(:http_delete).with("/services/data/v23/chatter/users/foo/status").and_return(true)
      Databasedotcom::Chatter::User.delete_status(@client_mock, "foo")
    end

    it "defaults the user id to 'me'" do
      @client_mock.should_receive(:http_delete).with("/services/data/v23/chatter/users/me/status").and_return(true)
      Databasedotcom::Chatter::User.delete_status(@client_mock)
    end
  end

  describe ".post_status" do
    before do
      @client_mock = double("client", :version => "23")
    end

    it "post a status update for the specified user" do
      @client_mock.should_receive(:http_post).with("/services/data/v23/chatter/users/foo/status", nil, :text => "new status").and_return(double("response", :body => "{}"))
      Databasedotcom::Chatter::User.post_status(@client_mock, "foo", "new status").should be_instance_of(Hash)
    end
  end

  describe ".conversations" do
    before do
      @client_mock = double("client", :version => "23")
    end

    it "gets the conversations for the specified user" do
      Databasedotcom::Chatter::Conversation.should_receive(:all).with(@client_mock, :user_id => "foo").and_return(double("response", :body => "{}"))
      Databasedotcom::Chatter::User.conversations(@client_mock, "foo")
    end
  end

  describe ".messages" do
    before do
      @client_mock = double("client", :version => "23")
    end

    it "gets the messages for the specified user" do
      Databasedotcom::Chatter::Message.should_receive(:all).with(@client_mock, :user_id => "foo").and_return(double("response", :body => "{}"))
      Databasedotcom::Chatter::User.messages(@client_mock, "foo")
    end
  end

  context "with an instantiated object" do
    before do
      @response = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/users_get_id_success_response.json"))
      @client_mock = double("client", :version => "23")
      @user = Databasedotcom::Chatter::User.new(@client_mock, @response)
    end

    describe "#status" do
      it "returns the user's status" do
        @user.status.should == @user.raw_hash["currentStatus"]
      end
    end

    describe "#post_status" do
      it "post a status for the user" do
        Databasedotcom::Chatter::User.should_receive(:post_status).with(@client_mock, @user.id, "new status")
        @user.post_status("new status")
      end
    end

    describe "#delete_status" do
      it "deletes the user's current status and returns what was deleted" do
        @client_mock.should_receive(:http_delete).with("/services/data/v23/chatter/users/#{@user.id}/status").and_return(true)
        @user.delete_status
      end
    end

    describe "#followers!" do
      it "gets the followers" do
        Databasedotcom::Chatter::User.should_receive(:followers).with(@client_mock, @user.id)
        @user.followers!
      end
    end

    describe "#followers" do
      it "gets the memoized followers" do
        Databasedotcom::Chatter::User.should_receive(:followers).with(@client_mock, @user.id).once.and_return("foo")
        @user.followers
        @user.followers
      end
    end

    describe "#following!" do
      it "gets the Following subscriptions" do
        Databasedotcom::Chatter::User.should_receive(:following).with(@client_mock, @user.id)
        @user.following!
      end
    end

    describe "#following" do
      it "gets the memoized following subscriptions" do
        Databasedotcom::Chatter::User.should_receive(:following).with(@client_mock, @user.id).once.and_return("foo")
        @user.following
        @user.following
      end
    end

    describe "#groups!" do
      it "gets the groups" do
        Databasedotcom::Chatter::User.should_receive(:groups).with(@client_mock, @user.id)
        @user.groups!
      end
    end

    describe "#groups" do
      it "gets the memoized groups" do
        Databasedotcom::Chatter::User.should_receive(:groups).with(@client_mock, @user.id).once.and_return("foo")
        @user.groups
        @user.groups
      end
    end

    describe "#follow" do
      it "follows the subject" do
        Databasedotcom::Chatter::User.should_receive(:follow).with(@client_mock, @user.id, "rid")
        @user.follow("rid")
      end
    end

    describe "#conversations!" do
      it "gets the conversations" do
        Databasedotcom::Chatter::User.should_receive(:conversations).with(@client_mock, @user.id)
        @user.conversations!
      end
    end

    describe "#conversations" do
      it "gets the memoized conversations" do
        Databasedotcom::Chatter::User.should_receive(:conversations).with(@client_mock, @user.id).once.and_return("foo")
        @user.conversations
        @user.conversations
      end
    end

    describe "#messages!" do
      it "gets the messages" do
        Databasedotcom::Chatter::User.should_receive(:messages).with(@client_mock, @user.id)
        @user.messages!
      end
    end

    describe "#messages" do
      it "gets the memoized messages" do
        Databasedotcom::Chatter::User.should_receive(:messages).with(@client_mock, @user.id).once.and_return("foo")
        @user.messages
        @user.messages
      end
    end
  end
end