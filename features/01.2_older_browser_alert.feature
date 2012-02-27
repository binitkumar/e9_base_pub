Feature: Older Browser Alert
  Scenario: I am visiting the site normally
    When I go to the home page
    Then I should not see "This site is optimized for modern, standards compliant browsers"

  Scenario: I am visiting the site with IE 5.5 I should see the warning page, once
    Given my browser is "MSIE 5.5"
    When I go to the home page
    Then I should see "This site is optimized for modern, standards compliant browsers"
    When I follow "Continue to Website"
    Then I should not see "This site is optimized for modern, standards compliant browsers"
