resource "azurerm_resource_group" "test_kov" {
  name     = "test-kov-resources"
  location = "East US"
}

resource "azurerm_storage_account" "test_kov_sa" {
  name                     = "test_kov_sa"
  resource_group_name      = azurerm_resource_group.test_kov.name
  location                 = azurerm_resource_group.test_kov.location
  body = jsonencode({
    kind = "StorageV2"
    properties = {
      accessTier                  = "Hot"
      allowBlobPublicAccess       = false
      allowCrossTenantReplication = false
      encryption = {
        keySource = "Microsoft.Storage"
        services = {
          blob = {
            enabled = true
            keyType = "Account"
          }
          file = {
            enabled = true
            keyType = "Account"
          }
        }
      }
      minimumTlsVersion = "TLS1_2"
     networkAcls = {
        bypass              = "AzureServices"
        defaultAction       = "Allow"
        ipRules             = []
        virtualNetworkRules = []
      }
      supportsHttpsTrafficOnly = true
    }
    sku = {
      name = "Standard_LRS"
    }
  })
  name      = "test_kov_sa"
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
