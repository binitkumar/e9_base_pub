Feature: SW-03.1 Sub nav blog case

  Background:
    Given the blog subnav is defined
    And there are 2 published blog posts from "May 1, 2010"
    And there are 2 published blog posts from "April 1, 2010"
    And there are 2 published blog posts from "Dec 1, 2009"

  Scenario: When I view the blog subnav
    When I go to the blog
    Then I should see the blog menu
