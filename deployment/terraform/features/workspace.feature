Feature: Azure Machine learning Workspace Compliance

  This is an example how an compliance test for the current
  Azure Machine Learning Workspace configuration might look like

  Scenario: Ensure Location is in West Europe
    Given I have azurerm_machine_learning_workspace defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure that identity is system assigned
    Given I have azurerm_machine_learning_workspace defined
    When it has identity
    Then its type must be SystemAssigned
