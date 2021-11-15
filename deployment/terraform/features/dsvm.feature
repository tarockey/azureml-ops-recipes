Feature: DSVM Compliance

  This is an example how an compliance test for the current
  Azure Data Science Virtual Machine configuration might look like

  Scenario: Ensure DSVM Location is in West Europe
    Given I have azurerm_virtual_machine defined
    Then it must contain location
    And its value must be westeurope

  Scenario Outline: Ensure DSVM image is using DSVM Build 2019 by Microsoft
    Given I have azurerm_virtual_machine defined
    When it contains storage_image_reference
    Then it must contain <key>
    And its value must be <value>

    Examples:
      | key       | value          |
      | publisher | microsoft-dsvm |
      | offer     | dsvm-win-2019  |
      | sku       | server-2019    |
      | version   | latest         |

  Scenario: Ensure that identity is system assigned
    Given I have azurerm_virtual_machine defined
    When it has identity
    Then its type must be SystemAssigned
