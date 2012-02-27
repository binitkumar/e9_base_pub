Feature: 04.0 Forum

  Scenario: Visiting the base forum
    Given 4 topics exist
    When I go to the forums page
    Then I should see all the topics

  Scenario: Visiting a particular forum
    Given a forum: "forum 1" exists with title: "Some forum"
    And a topic exists with title: "topic A", category: forum "forum 1"
    And another forum: "forum 2" exists
    And a topic exists with title: "topic B", category: forum "forum 2"
    When I go to the "Some forum" forum
    Then I should see "topic A"
    And I should not see "topic B"

  Scenario: Proper date formatting
    When I go to the forums page
    And a topic exists with created_at: "June 13, 2009 2:00PM"
    Then I should see "June 13, 2009, 2:00 PM"
