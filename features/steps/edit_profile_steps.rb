Given /^there are system and user mailing lists$/ do
  Factory.create(:hidden_mailing_list, :name => "non-signup list 1")
  Factory.create(:hidden_mailing_list, :name => "non-signup list 2")
  Factory.create(:mailing_list, :name => "signup list 1")
  Factory.create(:mailing_list, :name => "signup list 2")
end

Then /^I should see all the mailing lists$/ do
  MailingList.all.each do |list|
    Then %{I should see "#{list.description}"}
  end
end

When /^I want to edit my profile/ do
  visit edit_profile_path
end

When /^I attempt to view my profile$/ do
  visit profile_path
end
