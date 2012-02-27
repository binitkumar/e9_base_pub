Feature: SW-02.2 Main Nave - Forum Case
  Background:
    Given a forum menu is defined
    And there are 4 forum categories

  Scenario: I want to see the forums in the menu!
    When I go to the home page
    Then I should see the the site forum name within "a"
    And I should see the forum categories within "a"
