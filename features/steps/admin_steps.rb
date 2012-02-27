Given /^the following users:$/ do |users|
  # note this doesn't work because the admin user must be logged in to see the page
  users.hashes.each do |h| 
    Factory.create(:user, h)
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) user$/ do |pos|
  visit admin_users_url
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following users:$/ do |expected_users_table|
  expected_users_table.diff!(tableish('table tr', 'td,th'))
end
