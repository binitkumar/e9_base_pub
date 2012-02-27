Then /^I should see all the topics$/ do
  Topic.all do |topic|
    And %{I should see "#{topic.title}"}
  end
end
