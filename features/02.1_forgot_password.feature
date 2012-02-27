Feature: 02.1 Forgot Password

  Scenario: I want to find the forgot password page
    Given I go to sign in
    And I follow "Forgot your password?"
    Then I should be on Forgot password?

  Scenario: I have an account and try to recover my password
    Given I go to Forgot password?
    And I have a user with email "a@b.com" and password "asdfasdf"
    When I fill in "Email" with "a@b.com"
    And I press "Submit"
    Then I should be on sign in
    And I should see "You will receive an email with instructions about how to reset your password in a few minutes."

  Scenario: I don't have an account and try to recover my password
    Given I go to Forgot password?
    When I fill in "Email" with "a@b.com"
    And I press "Submit"
    And I should see "Email was not recognized."
