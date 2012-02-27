Feature: A01.1 Edit Users

  Scenario: Viewing the appropriate subscriptions
    Given there are system and user mailing lists
    And my role is "administrator"
    And I am editing a user with email "asdf@asdf.com"
    Then I should see all the mailing lists

  Scenario: I am a superuser and should see the role type field
    Given my role is "superuser"
    And I am editing a user with email "asdf@asdf.com"
    Then I should see the role type selector

  Scenario: I am an admin and should not see the role type field
    Given my role is "administrator"
    And I am editing a user with email "asdf@asdf.com"
    Then I should not see the role type selector
