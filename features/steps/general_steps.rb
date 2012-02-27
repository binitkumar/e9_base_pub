# set a config var
Given /Config "([^\"]*)" is "([^\"]*)"$/ do |arg1, arg2|
  key = arg1.downcase.gsub(/\s+/,'_')
  E9::Config[key] = arg2
  E9::Config[key].should == arg2
end

Given %r/Config "([^\"]*)" is true$/ do |arg1|
  E9::Config[arg1.downcase.gsub(/\s+/,'_')] = true
end

Given %r/Config "([^\"]*)" is false$/ do |arg1|
  E9::Config[arg1.downcase.gsub(/\s+/,'_')] = false
end

# simulate remote (to bypass local testing error raises)
Given %r/I am simulating a remote request$/ do
  set_headers "REMOTE-ADDR" => "10.0.1.1"
end

# poor man's pickle, should spend time to add multiple key/val
When %r/^a (\S+) exists with (\S+): "([^"]*)"$/ do |model, key, val|
  opts = { key.to_sym => val }
  Factory.create(model.to_sym, opts)
end

# setting/checking cookies
# TODO these don't work?
Then /^the cookie: "([^\"]*)" should be "([^\"]*)"$/ do |cookie_name, cookie_val|
  cookies[cookie_name].should == cookie_val
end

Then /^the cookie: "([^\"]*)" should be set$/ do |cookie_name|
  cookies[cookie_name].should_not be_nil
end

Given /^the cookie: "([^\"]*)" is "([^\"]*)"$/ do |cookie_name, cookie_val|
  cookies[cookie_name] = cookie_val
end

Given /^my browser is "([^\"]*)"$/ do |n|
  user_agent = case n
    when "MSIE 5.5" then "Mozilla/4.0 (compatible; MSIE 5.5;)"
  end

  set_headers "HTTP_USER_AGENT" => user_agent
end

