Given /^there are (\d+) users$/ do |num|
  (num.to_i - User.count).times do
    Factory.create(:user)
  end
  User.count.should == num.to_i
end

Then /^I should see (\d+) users$/ do |num|
  # rows in the table + 1 for the header
  all('tr').length.should == num.to_i + 1
end

Given /^there are (\d+) "([^\"]*)" users$/ do |num, role|
  (num.to_i - User.where(:role => role).count).times do
    Factory.create(:user, :role => role)
  end
  User.where(:role => role).count.should == num.to_i
end

Given /^there are (\d+) subscribers$/ do |num|
  while User.count < num.to_i
    Factory.create(:user)
  end
  Subscription.destroy_all
  m = Factory.create(:mailing_list)
  User.all[0,3].each do |u|
    Factory.create(:subscription, :user => u, :mailing_list => m)
  end
  User.subscribers.count.should == num.to_i
end
