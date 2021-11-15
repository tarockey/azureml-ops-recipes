Feature: Azure Storage Compliance

  This is an example how an compliance test for the current
  Azure Storage configuration might look like

  Scenario: Ensure Location is in West Europe
    Given I have azurerm_storage_account defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure minimum TLS version is set to 1.2
    Given I have azurerm_storage_account_network_rules defined
    Then it must contain min_tls_version
    And its value must be TLS1_2

  Scenario: Ensure that identity is system assigned
    Given I have azurerm_storage_account_network_rules defined
    When it has identity
    Then its type must be SystemAssigned

  Scenario: Ensure Network Rules are set and Deny access
    Given I have azurerm_storage_account_network_rules defined
    Then it must contain default_action
    And its value must be Deny

  Scenario: Ensure Network Rules are set and bypass Azure Services
    Given I have azurerm_storage_account_network_rules defined
    Then it must contain bypass
    And its value must be AzureServices
