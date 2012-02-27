Then /^I should see the site blog name within "([^\"]*)"$/ do |arg1|
  Then %{I should see "#{E9::Config['blog_name']}" within "#{arg1}"}
end

Then /^I should see the first 10 blog posts within "([^\"]*)"$/ do |arg1|
  BlogPost.recent(10).each do |bp|
    And %{I should see "#{bp.title}" within "#{arg1}"}
  end
end
