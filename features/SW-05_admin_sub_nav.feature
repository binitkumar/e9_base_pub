Feature: SW-05 Admin Sub Nav
  Background:
    Given the admin menu is defined
    And my role is "administrator"

  Scenario: Viewing the Admin Menu
    When I go to the home page
    And I follow "Admin"
    Then the admin menu should be visible
    And I should be on admin home

  Scenario: Hitting Admin Home
    When I go to admin home
    Then I should be on admin home

  Scenario: Hitting Users
    When I go to admin home
    And I follow "Users"
    Then I should be on admin users
    And I should see "Users" within "#admin-menu"
    And I should see "Flagged Posts" within "#admin-menu"

  Scenario: Hitting Content
    When I go to admin home
    And I follow "Content"
    Then I should be on admin pages
    And I should see "Pages" within "#admin-menu"
    And I should see "Menus" within "#admin-menu"
    And I should see "Categories" within "#admin-menu"
    And I should see "Share Sites" within "#admin-menu"
    And I should see "Layouts" within "#admin-menu"
    And I should not see "Admin Help" within "#admin-menu"
    When my role is "e9"
    And I go to admin home
    And I follow "Content"
    Then I should see "Admin Help" within "#admin-menu"

  Scenario: Hitting Email
    When I go to admin home
    And I follow "Email"
    Then I should be on pending email
    And I should see "Pending Email" within "#admin-menu"
    And I should see "Sent Email Log" within "#admin-menu"
    And I should see "System Email" within "#admin-menu"
    And I should see "Mailing Lists" within "#admin-menu"

  Scenario: Hitting Site
    When I go to admin home
    And I follow "Site"
    Then I should be on site settings
    And I should see "Site Settings" within "#admin-menu"
    And I should see "Search Log" within "#admin-menu"
    And I should see "Analytics" within "#admin-menu"

  Scenario: Hitting Help (with custom help)
    Given Config "custom_help" is true
    When I go to admin home
    And I follow "Help"
    Then I should be on admin help
    And I should see "Help" within "#admin-menu"
    And I should see "Custom Help" within "#admin-menu"
    Given Config "custom_help" is false
    And I follow "Help"
    Then I should not see "Custom Help" within "#admin-menu"
