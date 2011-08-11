require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Chatter::Record do
  it_should_behave_like("a restful resource")

  describe "with a constructed record" do
    before do
      @response = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/records_get_id_success_response.json"))
      @mock_client = double("client", :version => "23")
      @record = Databasedotcom::Chatter::Record.new(@mock_client, @response)
    end

    describe "#client" do
      it "returns the client of the standard record" do
        @record.client.should == @mock_client
      end
    end

    describe "#parent" do
      it "returns the parent of the record" do
        @record.parent.should == @record.raw_hash["parent"]
      end
    end

    describe "#user" do
      it "returns the user of the record" do
        @record.user.should == @record.raw_hash["user"]
      end
    end

    describe "#delete" do
      it "deletes the resource" do
        @mock_client.should_receive(:http_delete).with("/services/data/v23/chatter/records/#{@record.id}", {})
        @record.delete
      end
    end

    describe "#reload" do
      it "reloads the record" do
        @mock_client.should_receive(:http_get).with("/services/data/v23/chatter/records/#{@record.id}", {}).and_return(double("response", :body => @response))
        @record.reload
      end
    end

    it "provides getters for common attributes" do
      @record.name.should == "Admin User"
      @record.id.should == "005x0000000JbFuAAK"
      @record.url.should == "/services/data/v23.0/chatter/users/005x0000000JbFuAAK"
      @record.type.should == "User"
    end
  end
end

