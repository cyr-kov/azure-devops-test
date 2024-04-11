resource "azurerm_cdn_frontdoor_profile" "res-0" {
  name                     = "test2"
  resource_group_name      = "test1"
  response_timeout_seconds = 60
  sku_name                 = "Standard_AzureFrontDoor"
}
resource "azurerm_cdn_frontdoor_endpoint" "res-1" {
  cdn_frontdoor_profile_id = "/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Cdn/profiles/test2"
  name                     = "test3"
  depends_on = [
    azurerm_cdn_frontdoor_profile.res-0,
  ]
}
resource "azurerm_cdn_frontdoor_route" "res-2" {
  cdn_frontdoor_custom_domain_ids = ["/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Cdn/profiles/test2/customDomains/test1-kovtun-pro-9574"]
  cdn_frontdoor_endpoint_id       = "/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Cdn/profiles/test2/afdEndpoints/test3"
  cdn_frontdoor_origin_group_id   = "/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Cdn/profiles/test2/originGroups/default-origin-group"
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
  cdn_frontdoor_profile_id = "/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Cdn/profiles/test2"
  host_name                = "test1.kovtun.pro"
  name                     = "test1-kovtun-pro-9574"
  tls {
  }
  depends_on = [
    azurerm_cdn_frontdoor_profile.res-0,
  ]
}
resource "azurerm_cdn_frontdoor_origin_group" "res-4" {
  cdn_frontdoor_profile_id                                  = "/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Cdn/profiles/test2"
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
}
resource "azurerm_cdn_frontdoor_origin" "res-5" {
  cdn_frontdoor_origin_group_id  = "/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Cdn/profiles/test2/originGroups/default-origin-group"
  certificate_name_check_enabled = true
  host_name                      = "csb100320036c8d8a4e.blob.core.windows.net"
  name                           = "default-origin"
  origin_host_header             = "csb100320036c8d8a4e.blob.core.windows.net"
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-4,
  ]
}
resource "azurerm_cdn_frontdoor_security_policy" "res-7" {
  cdn_frontdoor_profile_id = "/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Cdn/profiles/test2"
  name                     = "test1"
  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = "/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Network/frontDoorWebApplicationFirewallPolicies/test1"
      association {
        patterns_to_match = ["/*"]
        domain {
          cdn_frontdoor_domain_id = "/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Cdn/profiles/test2/customDomains/test1-kovtun-pro-9574"
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
}
resource "azurerm_private_dns_zone" "res-9" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "test1"
}
resource "azurerm_private_dns_a_record" "res-10" {
  name                = "test1stora"
  records             = ["10.0.0.4"]
  resource_group_name = "test1"
  ttl                 = 3600
  zone_name           = "privatelink.blob.core.windows.net"
  depends_on = [
    azurerm_private_dns_zone.res-9,
  ]
}
resource "azurerm_private_dns_zone_virtual_network_link" "res-12" {
  name                  = "i5zkf7ykevcm2"
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  resource_group_name   = "test1"
  virtual_network_id    = "/subscriptions/ba33ff92-2b4d-4947-bc72-810a41391e7e/resourceGroups/test1/providers/Microsoft.Network/virtualNetworks/test1_net"
  depends_on = [
    azurerm_private_dns_zone.res-9,
    azurerm_virtual_network.res-13,
  ]
}
resource "azurerm_virtual_network" "res-13" {
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  name                = "test1_net"
  resource_group_name = "test1"
}
