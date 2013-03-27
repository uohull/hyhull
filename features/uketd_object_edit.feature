 Feature: Edit an ETD object

  Scenario: successful edit
  Given I am logged in as "contentAccessTeam1"
  And I am on the edit document page for "hull:756"
  Then I should see an inline edit containing "An investigation of the factors which influence the degree"
