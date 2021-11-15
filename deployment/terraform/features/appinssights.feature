Feature: Application Insights Compliance

  This is an example how an compliance test for the current
  Application Insights configuration might look like

  Scenario: Ensure Location is in West Europe
    Given I have azurerm_application_insights defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure that type is web
    Given I have azurerm_application_insights defined
    Then it must contain application_type
    Then its value must be web