output "databricks_url" { value = azurerm_databricks_workspace.dbw.workspace_url }
output "adf_name" { value = azurerm_data_factory.adf.name }