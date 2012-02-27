Feature: SW-08 Breadcrumbs
  
  Scenario: Should be empty on the home page
    When I go to the home page
    Then I should not see "Home" within "#breadcrumbs"
 
  Scenario: Should see blog name on blog pages
    When Config "blog_name" is "My Crazy Blog!"
    And I go to the blog
    Then I should see "Home" within "#breadcrumbs"
    And I should see "My Crazy Blog!" within "#breadcrumbs"

  Scenario: Should see forum name on forum pages
    When Config "forum_name" is "My Crazy Forum!"
    And I go to forums
    Then I should see "Home" within "#breadcrumbs"
    And I should see "My Crazy Forum!" within "#breadcrumbs"
