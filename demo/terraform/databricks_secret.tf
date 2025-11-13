resource "databricks_secret_scope" "kv" {
  name = "kv"
  # Standard (non‑Premium) workspaces require this exact value
  initial_manage_principal = "users"
  keyvault_metadata {
    resource_id = azurerm_key_vault.kv.id
    dns_name    = azurerm_key_vault.kv.vault_uri
  }
}
