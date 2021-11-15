Feature: Azure Container Registry Compliance

  This is an example how an compliance test for the current
  Azur Container Registry configuration might look like

  Scenario: Ensure Standard SKU is installed
    Given I have azurerm_container_registry defined
    Then it must contain SKU
    And its value must be Standard

  Scenario: Ensure Location is in West Europe
    Given I have azurerm_container_registry defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure that admin access is enabled
    Given I have azurerm_container_registry defined
    When it contains admin_enabled
    Then its value must be true
