Feature: 02.2 Reset Password

  Scenario: I have gotten the forgot password email and I attempt to change my password
    Given I have a user with email "a@b.com" and password "asdfasdf"
    And I reset my password and visit the link
    Then I should be on Reset Password
    When I fill in "Password" with "asdfasdf"
    And I fill in "Password confirmation" with "NOT asdfasdf"
    And I press "Change my password"
    Then I should see "Password must match confirmation."
    When I fill in "Password" with "qwerqwer"
    And I fill in "Password confirmation" with "qwerqwer"
    And I press "Change my password"
    Then I should see "Your password was changed successfully. You are now signed in."
    When I go to sign out
    Then I go to sign in
    And I fill in "sign_in_email" with "a@b.com"
    And I fill in "sign_in_password" with "asdfasdf"
    And I press "Sign in"
    Then I should see "invalid"
    Then I fill in "sign_in_password" with "qwerqwer"
    And I press "Sign in"
    Then I should be on my profile
