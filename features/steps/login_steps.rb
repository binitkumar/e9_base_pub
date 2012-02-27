#Given /^I am logged out$/ do
  #visit destroy_user_session_path
#end

#Given /^I have a user with email "([^\"]*)" and password "([^\"]*)"$/ do |arg1, arg2|
  #@logged_in_user = @my_user = Factory.create(:user, :email => arg1, :password => arg2, :password_confirmation => arg2)
#end

#Given /^I am logged in$/ do
  #@logged_in_user = Factory.create(:user)
  #And %{I sign in with email "#{@logged_in_user.email}" and password "#{@logged_in_user.password}"}
#end

#Given /^my "([^"]*)" is "([^"]*)"$/ do |arg1, arg2|
  #Then %{I am logged out}
  #And %{I am logged in}
  #@logged_in_user.update_attribute(arg1.to_sym, arg2)
  #@logged_in_user.reload.send(arg1).should == arg2
#end

#Given /^my role is "([^\"]*)"$/ do |role|
  #Then %{I am logged out}
  #Then %{I am logged in}
  #role = role.split(/\s+/).last.underscore
  #@logged_in_user.update_attribute(:role, role)
  #@logged_in_user.reload
  #@logged_in_user.role.should == Role.new(role)
#end
