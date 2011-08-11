require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe "string extensions" do
  describe "#resourcerize" do
    it "resourcerizes class names" do
      "FooBar".resourcerize.should == "foo-bar"
      "User".resourcerize.should == "user"
    end
  end
end
