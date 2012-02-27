require 'spec_helper'
require 'declarative_authorization/maintenance'

describe MailingList do
  include Authorization::TestHelper

  context "should be a non-system newsletter by default" do
    before { @mailing_list = Factory(:mailing_list) }
    it { @mailing_list.should be_valid }
    it { @mailing_list.should be_newsletter }
    it { @mailing_list.should_not be_system }
  end

  it "should have the lowest role by default" do
    Factory(:mailing_list).role.should == E9::Roles.bottom
  end

  describe "system mailing lists" do
    before { @mailing_list = Factory(:mailing_list, :system => true) }
    context "should not be destroyable by normal users" do
      before do
        begin
          @mailing_list.destroy
        rescue => @error
        end
      end
      it { @error.should be_a_kind_of(Authorization::NotAuthorized) }
      it { lambda{ MailingList.find(@mailing_list.id) }.should_not raise_error }
    end

    it "should be destroyable by top level users" do
      lambda { with_user(User.new(:role => E9::Roles.top)) { @mailing_list.destroy } }.should_not raise_error
    end
  end

  describe "having subscriptions" do
    before do
      @mailing_list = Factory(:mailing_list, :system => false)
      @subscriber   = Factory(:user)
      @subscription = Factory(:subscription, :user => @subscriber, :mailing_list => @mailing_list)
      @mailing_list.reload
    end

    context "should not be destroyable (even by e9)" do
      before do
        begin
          with_user(User.new(:role => E9::Roles.top)) do
            @mailing_list.destroy
          end
        rescue => @error
        end
      end
      it { @error.should be_an_instance_of(ActiveRecord::DeleteRestrictionError) }
      it { lambda{ MailingList.find(@mailing_list.id) }.should_not raise_error }
    end
  end
end
