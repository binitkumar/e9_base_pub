Feature: A01.0 Users

  Scenario: Viewing Users (not logged in)
    When I am logged out
    And I go to admin users
    Then I should be on the sign in page

  Scenario: Viewing Users (logged in as a public)
    When my role is "public"
    And I go to admin users
    Then I should be on the home page
    # cucumber or devise bug with flash and redirects
    # And I should see "Sorry, you are not allowed to access that page."

  Scenario: Viewing Users
    When my role is "administrator"
    And I go to admin users
    Then I should be on the admin users page

  Scenario: Searching Users
    Given a user exists with email "bob@asdf.com"
    And a user exists with first_name "qwerasdfqwer"
    And a user exists with last_name "asdfqwerqwer"  
    And a user exists with username "myusernameisasdf"
    And there are 10 users
    When my role is "administrator"
    And I go to admin users
    Then I should be on the admin users page
    And I fill in "Search" with "asdf"
    And I press "Go"
    Then I should see 4 users

  Scenario: Viewing correct numbers in thescope filter box
    Given there are 10 "superuser" users
    And there are 3 subscribers
    And there are 4 "employee" users
    When my role is "administrator"
    And I go to admin users
    Then I should see "Superusers (10)"
    And I should see "Subscribers (3)"
    And I should see "Employees (4)"
    # Commented til I figure out how to test Ajax
    # When I select "Subscribers" from "scope"
    # Then I should see 3 users
    # When I select "Superusers" from "scope"
    # Then I should see 10 users
