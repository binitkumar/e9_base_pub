Then /^I should see the the site forum name within "([^\"]*)"$/ do |arg1|
  Then %{I should see "#{E9::Config['forum_name']}" within "#{arg1}"}
end

Then /^I should see the forum categories within "([^\"]*)"$/ do |arg1|
  Forum.all.each do |f|
    And %{I should see "#{f.title}" within "#{arg1}"}
  end
end

