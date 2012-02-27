When /^I receive an email from the mailing list "([^\"]*)" and follow the unsubscribe link$/ do |arg1|
  @subscription = Factory.create(:subscription, :user => @my_user, :mailing_list => Factory(:mailing_list, :name => arg1))
  @my_user.reload.mailing_lists.should include(@subscription.mailing_list)
  visit edit_subscription_path(@subscription)
end

When /^I receive an email from the mailing list "([^\"]*)" and I follow the WRONG unsubscribe link$/ do |arg1|
  @subscription = Factory.create(:subscription, :user => @my_user, :mailing_list => Factory(:mailing_list, :name => arg1))
  @my_user.reload.mailing_lists.should include(@subscription.mailing_list)
  visit edit_subscription_path(@subscription).sub(/#{@subscription.unsubscribe_token}/, "somebadtoken")
end

When /^I am already unsubscribed from "([^\"]*)"$/ do |arg1|
  @my_user.subscriptions.destroy_all
  @my_user.reload
end

Then /^I should not be on the mailing list "([^\"]*)"$/ do |arg1|
  #@my_user.reload.mailing_lists.should_not include(MailingList.find_by_name(arg1))
  @my_user.reload.mailing_lists.should be_empty
end
