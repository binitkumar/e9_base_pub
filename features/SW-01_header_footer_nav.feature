Feature: SW-01 Header/Footer Nav Spec
  Background:
    Given the header nav is defined

  Scenario: When I am logged in as Employee I should see Employee content and not Admin content
    When my role is "employee"
    And I go to the home page
    Then I should see "Employees" within "#top-nav"
    And I should not see "Admin" within "#top-nav"

  Scenario: When I am logged in as Admin I should see Employee and Admin content
    When my role is "administrator"
    And I go to the home page
    Then I should see "Admin" within "#top-nav"
    And I should see "Employees" within "#top-nav"

  Scenario: When I am logged in as User I should see logged in content
    When my role is "user"
    And I go to the home page
    Then I should not see "Admin" within "#top-nav"
    And I should not see "Employees" within "#top-nav"
    And I should see "Edit Profile" within "#top-nav"
    And I should see "Sign Out" within "#top-nav"
    And I should see "My Home" within "#top-nav"

  Scenario: When I am not logged in I should see only logged out content
    When I am logged out
    And I go to the home page
    Then I should not see "Admin" within "#top-nav"
    And I should not see "Employees" within "#top-nav"
    And I should see "Sign Up" within "#top-nav"
