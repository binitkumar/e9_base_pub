Feature: 404 Error Page

  @allow-rescue
  Scenario: User hits a 404
    Given I am on the home page
    And Config "site_name" is "Some Crazy Site"
    And I am simulating a remote request
    When I go to a non-existant page
    And I should see "We can not find the requested page."
    And I should see "The Some Crazy Site Staff"
