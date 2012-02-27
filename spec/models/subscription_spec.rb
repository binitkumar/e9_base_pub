require 'spec_helper'

describe Subscription do
  it "should generate an unsub token" do
    Factory(:subscription).unsubscribe_token.should_not be_nil
  end
end
