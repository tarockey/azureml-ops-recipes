Feature: Bastion Compliance

  This is an example how an compliance test for the current
  Azure Bastion configuration might look like

  Scenario: Ensure Bastion Location is in West Europe
    Given I have azurerm_bastion_host defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure Bastion has a public static ip
    Given I have azurerm_public_ip defined
    Then it must contain allocation_method
    And its value must be Static

  Scenario: Ensure Bastion is using standard SKU
    Given I have azurerm_public_ip defined
    Then it must contain sku
    And its value must be Standard
