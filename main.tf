provider "azurerm" {
  features { }
  use_msi = true
}

terraform {
  backend "local" {}

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.77.0"

    }
  }
}

resource "azurerm_cdn_frontdoor_profile" "test_kov_profile" {
  name                     = "test2"
  resource_group_name      = "test1"
  response_timeout_seconds = 60
  sku_name                 = "Standard_AzureFrontDoor"
    
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_cdn_frontdoor_endpoint" "test_kov_endpoint" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test_kov_profile.id
  name                     = "test3"
  depends_on = [
    azurerm_cdn_frontdoor_profile.test_kov_profile,
  ]
    
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_cdn_frontdoor_route" "test_res_2" {
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.test_kov_custdom.id]
  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.test_kov_endpoint.id
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.test_kov_og.id 
  name                            = "default-route"
  patterns_to_match               = ["/*"]
  supported_protocols             = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.test_kov_endpoint,
    azurerm_cdn_frontdoor_custom_domain.test_kov_custdom,
    azurerm_cdn_frontdoor_origin_group.test_kov_og,
  ]
}
resource "azurerm_cdn_frontdoor_custom_domain" "test_kov_custdom" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test_kov_profile.id
  host_name                = "test1.kovtun.pro"
  name                     = "test1-kovtun-pro-9574"
  tls {
  }
  depends_on = [
    azurerm_cdn_frontdoor_profile.test_kov_profile,
  ]
    
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_cdn_frontdoor_origin_group" "test_kov_og" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.test_kov_profile.id
  name                                                      = "default-origin-group"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 100
    protocol            = "Http"
  }
  load_balancing {
  }
  depends_on = [
    azurerm_cdn_frontdoor_profile.test_kov_profile,
  ]
    
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_cdn_frontdoor_origin" "test_res_5" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.test_kov_og.id
  certificate_name_check_enabled = true
  host_name                      = "test_kov_sa.blob.core.windows.net"
  name                           = "default-origin"
  origin_host_header             = "test_kov_sa.blob.core.windows.net"
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.test_kov_og,
  ]
}
resource "azurerm_cdn_frontdoor_security_policy" "test_res_7" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test_kov_profile.id
  name                     = "test1"
  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.test_kov_firewall.id
      association {
        patterns_to_match = ["/*"]
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.test_kov_custdom.id
        }
      }
    }
  }
  depends_on = [
    azurerm_cdn_frontdoor_custom_domain.test_kov_custdom,
    azurerm_cdn_frontdoor_firewall_policy.test_kov_firewall,
  ]
}
resource "azurerm_cdn_frontdoor_firewall_policy" "test_kov_firewall" {
  mode                = "Detection"
  name                = "test1"
  resource_group_name = "test1"
  sku_name            = "Standard_AzureFrontDoor"
    
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_private_dns_zone" "test_res_9" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "test1"
}
