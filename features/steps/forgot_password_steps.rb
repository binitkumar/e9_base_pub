Given /^I reset my password and visit the link$/ do
  @my_user.send(:generate_reset_password_token!)
  visit edit_user_password_path(:reset_password_token => @my_user.reset_password_token)
end
