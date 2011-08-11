require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Chatter::Group do
  it_should_behave_like("a restful resource")
  it_should_behave_like("a resource with a photo")

  describe ".members" do
    before do
      @client_mock = double("client", :version => "23")
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/groups_members_get_id_success_response.json")))
    end

    it "gets a Collection of GroupMemberships" do
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/groups/gid/members").and_return(@response)
      Databasedotcom::Chatter::Group.members(@client_mock, "gid").should be_instance_of(Databasedotcom::Collection)
    end
  end

  describe ".join" do
    before do
      @client_mock = double("client", :version => "23")
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/group-memberships_get_id_success_response.json")))
    end

    it "joins the group" do
      @client_mock.should_receive(:http_post).with("/services/data/v23/chatter/groups/gid/members", nil, :userId => "me").and_return(@response)
      Databasedotcom::Chatter::Group.join(@client_mock, "gid", "me").should be_instance_of(Databasedotcom::Chatter::GroupMembership)
    end
  end

  context "with an instantiated Group" do
    before do
      grp = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/groups_get_id_success_response.json"))
      @client_mock = double("client", :version => "23")
      @response = double("response")
      @group = Databasedotcom::Chatter::Group.new(@client_mock, grp)
    end

    describe "#members!" do
      it "gets the members for the group" do
        Databasedotcom::Chatter::Group.should_receive(:members).with(@group.client, @group.id)
        @group.members!
      end
    end

    describe "#members" do
      it "gets the memoized members for the group" do
        Databasedotcom::Chatter::Group.should_receive(:members).with(@group.client, @group.id).once.and_return("foo")
        @group.members
        @group.members
      end
    end

    describe "#join" do
      it "joins the group" do
        Databasedotcom::Chatter::Group.should_receive(:join).with(@client_mock, @group.id, "me")
        @group.join
      end
    end
  end
end