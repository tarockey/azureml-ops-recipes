Feature: Key Vault Compliance

  This is an example how an compliance test for the current
  Azure Key Vault configuration might look like

  Scenario: Ensure Standard SKU is installed
    Given I have azurerm_key_vault defined
    Then it must contain sku_name
    And its value must be Standard

  Scenario: Ensure Location is in West Europe
    Given I have azurerm_key_vault defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure that purge protection is enabled
    Given I have azurerm_key_vault defined
    When it contains purge_protection_enabled
    Then its value must be true

  Scenario: Ensure that key permissions are correct
    Given I have azurerm_key_vault defined
    Then it must contain access_policy
    Then it must contain key_permissions
    Then its value must contain get
    And its value must contain create
    And its value must contain delete
    And its value must contain list
    And its value must contain restore
    And its value must contain recover
    And its value must contain unwrapkey
    And its value must contain wrapkey
    And its value must contain purge
    And its value must contain encrypt
    And its value must contain decrypt
    And its value must contain sign
    And its value must contain verify
    And its value must contain update


  Scenario: Ensure that secret permissions are correct
    Given I have azurerm_key_vault defined
    Then it must contain access_policy
    Then it must contain secret_permissions
    Then its value must contain set
    And its value must contain get
    And its value must contain delete
    And its value must contain list