require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Chatter::Subscription do
  it_should_behave_like("a restful resource")
end