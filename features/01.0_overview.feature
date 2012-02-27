Feature: Overview

  Scenario: Copyright info
    Given Config "site name" is "A Site Name"
    And Config "copyright start year" is "2010"
    When I go to the home page 
    Then I should see "2010 A Site Name"
    And when Config "copyright start year" is "2007"
    Then I go to the home page
    Then I should see "2007 - 2010 A Site Name"

  Scenario: E9 Tag
    When I go to the home page
    Then I should see "Web Design by E9 Digital"

  Scenario: Google Analytics
    Given Config "google analytics code" is "<script>Some Code</script>"
    When I go to the home page
    Then I should see "Some Code" within "script"
