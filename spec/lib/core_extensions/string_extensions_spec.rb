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

  describe "#constantize" do
    context "when string is empty" do
      it "raises a NameError" do
        expect {
          "".constantize
        }.to raise_error(NameError)
      end
    end

    context "when string ends with ::" do
      it "returns Object" do
        "Object::".constantize.should eq(Object)
      end
    end
  end
end
