output "function_app_id" {
  value       = azurerm_linux_function_app.fa.id
  description = "ID de la Function App."
}

output "function_app_name" {
  value       = azurerm_linux_function_app.fa.name
  description = "Nombre de la Function App."
}

output "default_hostname" {
  value       = azurerm_linux_function_app.fa.default_hostname
  description = "Hostname por defecto."
}

output "service_plan_id" {
  value       = azurerm_service_plan.plan.id
  description = "ID del Service Plan."
}

output "storage_account_name" {
  value       = azurerm_storage_account.sa.name
  description = "Storage Account usado por la Function App."
}

output "app_insights_connection_string" {
  value       = try(azurerm_application_insights.ai[0].connection_string, null)
  description = "Connection string de App Insights (si habilitado)."
}
