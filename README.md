# Azure Function App - Golden Module

## Naming estándar
- Function App: {entity}-{environment}-{app_name}-func-01 (auto si function_app_name = null)

## Tags estándar
- entity, environment, app_name, cost_center, tracking_code
- custom_tags (opcional)
- hidden-deploy=curated (interno)
- inherit tags desde RG (opcional)

## Incluye
- Storage Account
- Service Plan (Consumption/Premium/Dedicated según sku_name)
- Linux Function App
- Application Insights (opcional)
- VNet Integration (opcional)

## Ejemplo mínimo
```hcl
module "fa" {
  source = "./modules/function_app"

  entity        = "ClaroChile"
  environment   = "dev"
  app_name      = "esim-orchestrator"
  cost_center   = "CC-IT-001"
  tracking_code = "PRJ-ESIM-2026"

  rsg_name  = "cl-rg-dev-esim-01"
  location  = "eastus2"

  publisher_email = "N/A" # (no aplica aquí)
}# Azure-Functions
