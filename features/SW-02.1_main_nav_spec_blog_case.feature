Feature: SW-02.1 Main Nave - Blog Case
  Background:
    Given a blog menu is defined
    And there are 12 published blog posts

  Scenario: I want to see the blog in the menu!
    When I go to the home page
    Then I should see the site blog name within "a"
    And I should see the first 10 blog posts within "a"
