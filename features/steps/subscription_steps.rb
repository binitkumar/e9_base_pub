Given /^I have no subscriptions$/ do
  @logged_in_user.subscriptions.destroy_all
end

Given /^there is a ([\w\s]+) with ([\w\s]+) "([^\"]*)" and ([\w\s]+) "([^\"]*)"$/ do |model, key1, val1, key2, val2|
  m = model.gsub(/\s+/,'_').to_sym
  Factory.create(m, key1.to_sym => val1, key2.to_sym => val2)
end

Given /^I have a subscription to the "([^\"]*)" mailing list$/ do |arg1|
  Then %{I have no subscriptions}
  ml = MailingList.create(:name => "somename", :description => arg1)
  @logged_in_user.subscriptions.create(:mailing_list => ml)
end

Then /^I should have no subscriptions$/ do
  @logged_in_user.reload.subscriptions.should == [] 
end
