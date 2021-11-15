Feature: VNet Compliance

  This is an example how an compliance test for the current
  Azure Virtual Network configuration might look like

  Scenario: Ensure Virtual Network address space is correct
    Given I have azurerm_virtual_network defined
    Then it must contain address_space
    And its value must be 10.0.0.0/20

  Scenario: Ensure VNet Location is in West Europe
    Given I have azurerm_virtual_network defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure multiple subnets
    Given I have azurerm_subnet defined
    When I count them
    Then its value must be 3

  Scenario Outline: Ensure address space is correctly defined in Subnets
    Given I have azurerm_subnet defined
    When its name is <subnet>
    Then it must contain address_prefixes
    And its value must be <addrprefix>

    Examples:
      | subnet             | addrprefix  |
      | AzureBastionSubnet | 10.0.0.0/27 |
      | AMLSubnet          | 10.0.1.0/24 |
      | DSVMSubnet         | 10.0.2.0/24 |

