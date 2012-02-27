When /^I am editing a user with email "([^\"]+)"$/ do |email|
  @editing_user = User.find_by_email(email) || Factory.create(:user, :email => email)
  visit edit_admin_user_path(@editing_user)
  And %{I should be on the edit user page for "#{@editing_user.email}"}
end

Then /^I should see the role type selector$/ do
  page.should have_xpath("//input[@name='user[role]']")
end

Then /^I should not see the role type selector$/ do
  page.should_not have_xpath("//input[@name='user[role]']")
end

