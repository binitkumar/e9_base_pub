Feature: 02.0 Sign In / Sign Up

  Scenario: Accessing a page that requires sign in
    Given I am logged out
    When I attempt to view my profile
    Then I should be on Sign In 
    And I should see "You need to sign in or sign up before continuing." 

  Scenario: Signing in with a non-existent user
    Given I am logged out
    When I go to sign in
    And no user exists with email: "someemail@example.com"
    And I fill in "sign_in_email" with "someemail@example.com"
    And I fill in "sign_in_password" with "asdfasdf"
    And I press "Sign in"
    Then I should see "Email Address or Password is invalid."

  Scenario: Signing in with an invalid email
    Given I am logged out
    When I go to sign in
    And I fill in "sign_in_email" with "an invalid email"
    And I fill in "sign_in_password" with "asdfasdf"
    And I press "Sign in"
    Then I should see "Email Address or Password is invalid."

  Scenario: Entering an incorrect password
    Given I am logged out
    When I go to sign in
    And I have a user with email "some@email.com" and password "asdfasdf"
    And I fill in "sign_in_email" with "some@email.com"
    And I fill in "sign_in_password" with "NOTasdfasdf"
    And I press "Sign in"
    Then I should see "Email Address or Password is invalid."

  Scenario: Registering with valid parameters
    When I want to sign up
    And I fill in the sign up form with valid parameters
    And I press "Sign up"
    Then I should see "Thanks for registering. You can customize your profile, preferences, and avatar by going to Edit Profile."
    And I should be on my profile page

  Scenario: Registering with an invalid email
    When I want to sign up
    And I fill in the sign up form with valid parameters
    And I fill in "sign_up_email" with "an invalid email"
    And I press "Sign up"
    Then I should see "Email is not properly formatted."

  Scenario: Registering with a duplicate email
    When I want to sign up
    And I fill in the sign up form with valid parameters
    And I fill in "sign_up_email" with "asdf@asdf.com"
    And a user exists with email: "asdf@asdf.com"
    And I press "Sign up"
    Then I should see "Email is already in the system."

  Scenario: Registering with a duplicate username
    When I want to sign up
    And I fill in the sign up form with valid parameters
    And I fill in "sign_up_username" with "somename"
    And a user exists with username: "somename"
    And I press "Sign up"
    Then I should see "Username is already in the system."

  Scenario: Registering with duplicate passwords
    When I want to sign up
    And I fill in the sign up form with valid parameters
    And I fill in "sign_up_password" with "somepass"
    And I fill in "sign_up_password_confirmation" with "NOTsomepass"
    And I press "Sign up"
    Then I should see "Password must match confirmation."

  Scenario: Registering with fields of incorrect length
    When I want to sign up
    And I fill in the sign up form with valid parameters
    And I fill in "sign_up_username" with over 25 characters
    And I press "Sign up"
    Then I should see "Username is limited to 25 characters"
    And I fill in the sign up form with valid parameters
    And I fill in "sign_up_first_name" with over 25 characters
    And I press "Sign up"
    Then I should see "First name is limited to 25 characters"

  Scenario: I should see the system and user created newsletters, system should be checked, user unchecked
    When there is a system mailing list with description "some description"
    And there is a user mailing list with description "some other description"
    And I want to sign up
    Then the "some description" checkbox should be checked 
    And the "some other description" checkbox should not be checked

  Scenario: When I sign up I should have the default role "user"
    When I sign up
    Then my user role should be "user"
