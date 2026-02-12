#####################################
# Tags estándar (obligatorios)
#####################################

entity        = "ClaroChile"
environment   = "dev"          # dev | pre | pro
app_name      = "esim-datafactory"
cost_center   = "CC-IT-001"
tracking_code = "PRJ-ESIM-2026"

#####################################
# Resource Group / Ubicación
#####################################

rsg_name      = "rg-poc-test-001"
location      = "chilecentral"
subscriptionid = "ef0a94be-5750-4ef8-944b-1bbc0cdda800"
tenantid = "fe6c41e5-a3e4-4d16-82df-1b33029102eb"

#####################################
# Azure Functions
#####################################

plan_sku_name = "Y1"      # Consumption
plan_os_type  = "Linux"

application_stack = {
  node_version = "18"
  }

enable_app_insights = true

app_settings = {
  "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
