resource "azurerm_resource_group" "test_kov" {
  name     = "test-kov-resources"
  location = "East US"
}

resource "azurerm_storage_account" "test_kov_sa" {
  name                     = "test_kov_sa"
  account_tier = "Standart"
  account_replication_type = "LRS"
  resource_group_name      = azurerm_resource_group.test_kov.name
  location                 = azurerm_resource_group.test_kov.location
  account_kind = "StorageV2"
  cross_tenant_replication_enabled = false
  access_tier = "Hot"
  allow_nested_items_to_be_public = false
  min_tls_version = "TLS1_2"
  is_hns_enabled = true
  network_rules = {

  }
    #   encryption = {
    #     keySource = "Microsoft.Storage"
    #     services = {
    #       blob = {
    #         enabled = true
    #         keyType = "Account"
    #       }
    #       file = {
    #         enabled = true
    #         keyType = "Account"
    #       }
    #     }
    #   }
    #  networkAcls = {
    #     bypass              = "AzureServices"
    #     defaultAction       = "Allow"
    #     ipRules             = []
    #     virtualNetworkRules = []
    #   }
    #   supportsHttpsTrafficOnly = true
    # }

  tags = {
    ms-resource-usage = "azure-cloud-shell"
  }
  type = "Microsoft.Storage/storageAccounts@2023-01-01"
}

resource "azurerm_storage_container" "test_kov_cn" {
  name                  = "test2"
  storage_account_name  = azurerm_storage_account.test_kov_sa.name
  container_access_type = "private"
}
