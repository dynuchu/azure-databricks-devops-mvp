locals {
  rg_name             = "${var.prefix}-rg"
  ai_endpoint_unified = "https://${azurerm_cognitive_account.ai.name}.cognitiveservices.azure.com"
}