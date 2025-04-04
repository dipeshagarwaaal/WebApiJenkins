provider "azurerm" {
  features {}

  client_id       = "2fb998ec-1f1d-4682-b420-94fb5ee1aeac"
  client_secret   = ".TJ8Q~qsn1iL-aMK1SLwGjtpKR~_ECVrGk_1Qb5W"
  tenant_id       = "1a7c998d-d7c1-4821-9e89-e43b6077ecea"
  subscription_id = "e5128466-7604-4126-8601-6727d13dbe7e"
}

resource "azurerm_resource_group" "example" {
  name     = "jenkins-rg"
  location = "East US"
}

resource "azurerm_app_service_plan" "example" {
  name                = "jenkins-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "jenkins-web-app123"  # Must be globally unique
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    always_on = true
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}
