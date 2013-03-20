Feature: Homepage
  I want the home page to reflect localisations properly

  Scenario: home page text
    When I am on the home page
    Then I should not see "override"
    And I should see "Welcome to Hull's digital repository, Hydra"

