Given /^I want to sign up$/ do
  visit destroy_user_session_path
  visit new_user_session_path
end

Given /^I fill in the sign up form with valid parameters$/ do
  And %{I fill in "sign_up_email" with "someemail@example.com"} 
  And %{I fill in "sign_up_first_name" with "somename"}
  And %{I fill in "sign_up_password" with "asdfasdf"}
  And %{I fill in "sign_up_password_confirmation" with "asdfasdf"}
  And %{I fill in "sign_up_username" with "somename"}
end

Given /^I am logged in (?:as a user )with email "([^\"]*)" and password "([^\"]*)"$/ do |arg1, arg2| 
  Then %{I have a user with email "#{arg1}" and password "#{arg2}"}
  @logged_in_user = @my_user
  And %{I sign in with email "#{@my_user.email}" and password "#{@my_user.password}"}
end

Given /^I sign in with email "([^\"]*)" and password "([^\"]*)"$/ do |arg1, arg2|
  Then %{I go to sign in}
  And %{I fill in "sign_in_email" with "#{arg1}"}
  And %{I fill in "sign_in_password" with "#{arg2}"}
  And %{I press "Sign in"}
end

When /^I sign out and sign in with email "([^\"]*)" and password "([^\"]*)"$/ do |arg1, arg2|
  Then %{I go to sign out}
  And %{I sign in with email "#{arg1}" and password "#{arg2}"}
end

When /^no user exists with email: "([^\"]*)"$/ do |arg1|
  if user = User.find_by_email(arg1)
    user.destroy
  end
end

When /^I fill in "([^\"]*)" with over (\d+) characters$/ do |arg1, n|
  And %{I fill in "#{arg1}" with "#{'a' * n.to_i.succ}"}
end

When /^there is a system mailing list with description "([^\"]*)"$/ do |arg1|
  Factory.create(:mailing_list, :description => arg1, :system => true)
end

When /^there is a user mailing list with description "([^\"]*)"$/ do |arg1|
  Factory.create(:mailing_list, :description => arg1, :system => false)
end

When /^I sign up$/ do
  And %{I want to sign up}
  And %{I fill in the sign up form with valid parameters}
  And %{I press "Sign up"}
  @logged_in_user = User.order('created_at ASC').last
end

Then /^my user role should be "([^\"]*)"$/ do |arg1|
  @logged_in_user.role.should == arg1
end
