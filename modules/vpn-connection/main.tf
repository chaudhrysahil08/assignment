# Data source to get the current client's tenant and object ID
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                        = "kv-myvpnsecrets-01" # Unique name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false # Set to true for production!

  # IMPORTANT: Add access policy for your service principal/managed identity
  # that runs Terraform to be able to set and get secrets.
  # This example grants permissions for the user running Terraform.
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id # Your user/SP object ID

    secret_permissions = [
      "Set", "Get", "Delete", "List" # "Set" to create, "Get" to read
    ]
  }
}

# --- Generate and Store Shared Key ---
resource "random_string" "vpn_shared_key" {
  length  = 32 # A good length for an IPsec shared key
  special = true
  upper   = true
  lower   = true
  numeric = true
  override_special = "!@#$%&*-_=+" # Characters to use in the key
}

resource "azurerm_key_vault_secret" "vpn_shared_key" {
  name         = "vpn-shared-key"
  value        = random_string.vpn_shared_key.result
  key_vault_id = azurerm_key_vault.main.id
  content_type = "IPsec Shared Key" # Optional, for description
}

resource "azurerm_virtual_network_gateway_connection" "main" {
  name                = var.connection_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = var.virtual_network_gateway_id
  peer_virtual_network_gateway_id = var.peer_virtual_network_gateway_id
  
  shared_key = azurerm_key_vault_secret.vpn_shared_key.value
  
  tags = var.tags
}