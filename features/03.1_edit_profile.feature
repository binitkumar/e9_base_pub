Feature: 03.1 Edit Profile

  Scenario: Edit my profile
    Given I am logged in
    When I want to edit my profile
    And I fill in "First name" with "Testy"
    And I press "Update User"
    Then I should see "Profile settings successfully updated."
    And I should be on my profile
    And I should see "Testy"

  Scenario: Viewing the appropriate subscriptions
    Given there are system and user mailing lists
    And I am logged in
    And I go to edit my profile
    Then I should see all the mailing lists

  Scenario: Add a subscription from my profile
    Given I am logged in
    And I have no subscriptions
    And there is a mailing list with name "email updates" and description "email list description"
    And I go to edit my profile
    When I check "email list description"
    And I press "Update User"
    Then I should see "Profile settings successfully updated."
    When I go to edit my profile
    Then the "email list description" checkbox should be checked 

  Scenario: Remove a subscription from my profile
    Given I am logged in
    And I have a subscription to the "email list description" mailing list
    When go to edit my profile
    And I uncheck "email list description"
    And I press "Update User"
    Then I should see "Profile settings successfully updated."
    And I should have no subscriptions

  Scenario: Change my password
    Given I am logged in as a user with email "some@email.com" and password "asdfasdf"
    And I go to edit my profile
    And I fill in "Password" with "qwerqwer"
    And I fill in "Password confirmation" with "qwerqwer"
    And I press "Update User"
    Then I should see "Profile settings successfully updated."
    When I sign out and sign in with email "some@email.com" and password "qwerqwer"
    Then I should be on my profile
