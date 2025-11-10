resource "azurerm_cognitive_account" "ai" {
  name                = "${var.prefix}-cog-ai-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "CognitiveServices"
  sku_name            = "S0"
}

resource "azurerm_key_vault_access_policy" "current" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "Set"]
}

resource "azurerm_key_vault_secret" "ai_primary_key" {
  name         = "ai-primary-key"
  value        = azurerm_cognitive_account.ai.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.current]
}