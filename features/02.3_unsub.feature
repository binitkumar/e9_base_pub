Feature: 02.3 Unsub

  Scenario: I want to unsubscribe through an email link
    Given I have a user with email "some@email.com" and password "asdfasdf"
    When I receive an email from the mailing list "email updates" and follow the unsubscribe link
    Then I should be on my unsubscribe page for "email updates"
    When I press "Unsubscribe from email updates"
    Then I should be on the home page
    And I should not be on the mailing list "email updates"
    And I should see "some@email.com is now unsubscribed from email updates."

  Scenario: I want to unsubscribe but I somehow follow a bad link (token)
    Given I have a user with email "some@email.com" and password "asdfasdf"
    When I receive an email from the mailing list "email updates" and I follow the WRONG unsubscribe link
    Then I should be on the unsubscribe page
    Then I should see "We did not recognize that email. Please check the URL and try again."

  Scenario: I am not subscribed, but I try to unsubscribe
    Given I have a user with email "some@email.com" and password "asdfasdf"
    When I receive an email from the mailing list "email updates" and follow the unsubscribe link
    But I am already unsubscribed from "email updates"
    When I press "Unsubscribe from email updates"
    Then I should be on the home page
    And I should not be on the mailing list "email updates"
    Then show me the page
    And I should see "You are now unsubscribed from the mailing list."
