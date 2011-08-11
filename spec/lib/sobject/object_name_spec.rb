require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Sobject::ObjectName do
  describe "#singular" do
    it "returns the name" do
      Databasedotcom::Sobject::ObjectName.new("foo").singular.should == "foo"
    end
  end
end