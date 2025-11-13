resource "azurerm_data_factory_linked_service_key_vault" "ls_kv" {
  name            = "ls-kv"
  data_factory_id = azurerm_data_factory.adf.id
  key_vault_id    = azurerm_key_vault.kv.id
}

resource "azurerm_data_factory_pipeline" "ai_web_call" {
  name            = "pl-ai-web-call"
  data_factory_id = azurerm_data_factory.adf.id

  # biztosítsuk a sorrendet: előbb legyen LS és secret
  depends_on = [
    azurerm_data_factory_linked_service_key_vault.ls_kv,
    azurerm_key_vault_secret.ai_primary_key
  ]

  activities_json = <<JSON
[
  {
    "name": "CallAzureAI",
    "type": "WebActivity",
    "typeProperties": {
      "method": "POST",
      "url": "https://swedencentral.api.cognitive.microsoft.com/language/:analyze-text?api-version=2023-04-01",
      "headers": {
        "Content-Type": "application/json",
        "Ocp-Apim-Subscription-Region": "swedencentral",
        "Ocp-Apim-Subscription-Key": {
          "type": "AzureKeyVaultSecret",
          "store": { "referenceName": "${azurerm_data_factory_linked_service_key_vault.ls_kv.name}", "type": "LinkedServiceReference" },
          "secretName": "ai-primary-key"
        }
      },
      "body": ${jsonencode({
        kind          = "KeyPhraseExtraction",
        parameters    = { modelVersion = "latest" },
        analysisInput = { documents = [{ id = "1", language = "en", text = "ADF talking to Azure AI via KV secret." }] }
      })}
    }
  }
]
JSON
}
