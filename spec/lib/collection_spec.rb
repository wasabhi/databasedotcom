require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Collection do
  before do
    @client_mock = double("client")
    @collection = Databasedotcom::Collection.new(@client_mock, 10, "http://next.page.url", "http://previous.page.url", "http://current.page.url")
  end

  it "is an Array" do
    @collection.should be_a_kind_of(Array)
  end

  it "has a total size" do
    @collection.total_size.should == 10
  end

  it "has a client" do
    @collection.client.should == @client_mock
  end

  it "has a current page url" do
    @collection.current_page_url.should == "http://current.page.url"
  end

  describe "#next_page?" do
    it "returns true if a next page url exists" do
      @collection.next_page?.should be_true
    end

    it "returns false if no next page url exists" do
      Databasedotcom::Collection.new(@client_mock, 10).next_page?.should be_false
    end
  end

  describe "#next_page" do
    context "when a next page url exists" do
      it "creates a new collection" do
        @client_mock.should_receive(:next_page).with(@collection.next_page_url).and_return("foo")
        new_collection = @collection.next_page
        new_collection.should == "foo"
      end
    end

    context "when no next page url exists" do
      it "returns an empty collection" do
        @collection.stub(:next_page_url).and_return(nil)
        @client_mock.should_not_receive(:next_page)
        new_collection = @collection.next_page
        new_collection.should be_an_instance_of(Databasedotcom::Collection)
        new_collection.length.should be_zero
      end
    end
  end

  describe "#previous_page?" do
    it "returns true if a previous page url exists" do
      @collection.previous_page?.should be_true
    end

    it "returns false if no previous page url exists" do
      Databasedotcom::Collection.new(@client_mock, 10).previous_page?.should be_false
    end
  end

  describe "#previous_page" do
    context "when a previous page url exists" do
      it "creates a new collection" do
        @client_mock.should_receive(:previous_page).with(@collection.previous_page_url).and_return("foo")
        new_collection = @collection.previous_page
        new_collection.should == "foo"
      end
    end

    context "when no previous page url exists" do
      it "returns an empty collection" do
        @collection.stub(:previous_page_url).and_return(nil)
        @client_mock.should_not_receive(:previous_page)
        new_collection = @collection.previous_page
        new_collection.should be_an_instance_of(Databasedotcom::Collection)
        new_collection.length.should be_zero
      end
    end
  end
end