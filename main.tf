provider "azurerm" {
  features {
  }
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

resource "azurerm_cdn_frontdoor_profile" "res-0" {
  name                     = "test2"
  resource_group_name      = "test1"
  response_timeout_seconds = 60
  sku_name                 = "Standard_AzureFrontDoor"
    
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_cdn_frontdoor_endpoint" "res-1" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.res-0.id
  name                     = "test3"
  depends_on = [
    azurerm_cdn_frontdoor_profile.res-0,
  ]
    
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_cdn_frontdoor_route" "res-2" {
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.res-3.id]
  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.res-1.id
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.res-4.id 
  name                            = "default-route"
  patterns_to_match               = ["/*"]
  supported_protocols             = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.res-1,
    azurerm_cdn_frontdoor_custom_domain.res-3,
    azurerm_cdn_frontdoor_origin_group.res-4,
  ]
}
resource "azurerm_cdn_frontdoor_custom_domain" "res-3" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.res-0.id
  host_name                = "test1.kovtun.pro"
  name                     = "test1-kovtun-pro-9574"
  tls {
  }
  depends_on = [
    azurerm_cdn_frontdoor_profile.res-0,
  ]
    
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_cdn_frontdoor_origin_group" "res-4" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.res-0.id
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
    azurerm_cdn_frontdoor_profile.res-0,
  ]
    
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_cdn_frontdoor_origin" "res-5" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-4.id
  certificate_name_check_enabled = true
  host_name                      = "test_kov_sa.blob.core.windows.net"
  name                           = "default-origin"
  origin_host_header             = "test_kov_sa.blob.core.windows.net"
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-4,
  ]
}
resource "azurerm_cdn_frontdoor_security_policy" "res-7" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.res-0.id
  name                     = "test1"
  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.res-8.id
      association {
        patterns_to_match = ["/*"]
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.res-3.id
        }
      }
    }
  }
  depends_on = [
    azurerm_cdn_frontdoor_custom_domain.res-3,
    azurerm_cdn_frontdoor_firewall_policy.res-8,
  ]
}
resource "azurerm_cdn_frontdoor_firewall_policy" "res-8" {
  mode                = "Detection"
  name                = "test1"
  resource_group_name = "test1"
  sku_name            = "Standard_AzureFrontDoor"
    
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_private_dns_zone" "res-9" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "test1"
}
