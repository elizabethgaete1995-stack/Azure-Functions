data "azurerm_resource_group" "rsg_principal" {
  name = var.rsg_name
}

locals {
  private_tags = { "hidden-deploy" = "curated" }

  standard_tags = {
    entity        = var.entity
    environment   = lower(var.environment)
    app_name      = var.app_name
    cost_center   = var.cost_center
    tracking_code = var.tracking_code
  }

  tags           = merge(local.standard_tags, local.private_tags, var.custom_tags)
  tags_inherited = merge(data.azurerm_resource_group.rsg_principal.tags, local.private_tags, local.standard_tags, var.custom_tags)
  effective_tags = var.inherit ? local.tags_inherited : local.tags

  # slugify simple
  entity_slug = lower(regexreplace(replace(replace(trim(var.entity), " ", "-"), "_", "-"), "[^a-z0-9-]", ""))
  env_slug    = lower(regexreplace(replace(replace(trim(var.environment), " ", "-"), "_", "-"), "[^a-z0-9-]", ""))
  app_slug    = lower(regexreplace(replace(replace(trim(var.app_name), " ", "-"), "_", "-"), "[^a-z0-9-]", ""))

  generated_function_name = "${local.entity_slug}-${local.env_slug}-${local.app_slug}-${var.name_suffix}"
  effective_function_name = (var.function_app_name != null && trim(var.function_app_name) != "") ? var.function_app_name : local.generated_function_name

  generated_plan_name  = "${local.entity_slug}-${local.env_slug}-${local.app_slug}-plan-01"
  effective_plan_name  = (var.plan_name != null && trim(var.plan_name) != "") ? var.plan_name : local.generated_plan_name

  # Storage account: debe ser lowercase alfanumérico y <=24; generamos algo seguro (sin guiones) y truncamos.
  sa_base = substr(regexreplace("${local.entity_slug}${local.env_slug}${local.app_slug}sa01", "[^a-z0-9]", ""), 0, 24)
  effective_sa_name = (var.storage_account_name != null && trim(var.storage_account_name) != "") ? lower(var.storage_account_name) : local.sa_base

  generated_ai_name = "${local.entity_slug}-${local.env_slug}-${local.app_slug}-ai-01"
  effective_ai_name = (var.app_insights_name != null && trim(var.app_insights_name) != "") ? var.app_insights_name : local.generated_ai_name
}

#########################
# Storage Account
#########################
resource "azurerm_storage_account" "sa" {
  name                     = local.effective_sa_name
  resource_group_name      = data.azurerm_resource_group.rsg_principal.name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type

  min_tls_version = "TLS1_2"

  tags = local.effective_tags

  lifecycle {
    precondition {
      condition     = can(regex("^[a-z0-9]{3,24}$", local.effective_sa_name))
      error_message = "storage_account_name debe ser lowercase alfanumérico (3-24). Actual: ${local.effective_sa_name}"
    }
  }
}

#########################
# Service Plan
#########################
resource "azurerm_service_plan" "plan" {
  name                = local.effective_plan_name
  resource_group_name = data.azurerm_resource_group.rsg_principal.name
  location            = var.location

  os_type  = var.plan_os_type
  sku_name = var.plan_sku_name

  tags = local.effective_tags
}

#########################
# Application Insights (opcional)
#########################
resource "azurerm_application_insights" "ai" {
  count               = var.enable_app_insights ? 1 : 0
  name                = local.effective_ai_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rsg_principal.name
  application_type    = var.app_insights_type

  tags = local.effective_tags
}

#########################
# Function App (Linux)
#########################
resource "azurerm_linux_function_app" "fa" {
  name                = local.effective_function_name
  resource_group_name = data.azurerm_resource_group.rsg_principal.name
  location            = var.location

  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key

  https_only                 = var.https_only
  functions_extension_version = var.functions_extension_version

  dynamic "identity" {
    for_each = var.identity_type == "None" ? [] : [1]
    content {
      type         = var.identity_type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? var.user_assigned_identity_ids : null
    }
  }

  site_config {
    always_on = var.always_on

    application_stack {
      node_version   = try(var.application_stack.node_version, null)
      dotnet_version = try(var.application_stack.dotnet_version, null)
      java_version   = try(var.application_stack.java_version, null)
      python_version = try(var.application_stack.python_version, null)
    }
  }

  app_settings = merge(
    var.app_settings,
    var.enable_app_insights ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.ai[0].connection_string
    } : {}
  )

  tags = local.effective_tags

  lifecycle {
    precondition {
      condition     = !(var.enable_vnet_integration && (var.subnet_id == null || trim(var.subnet_id) == ""))
      error_message = "Si enable_vnet_integration=true, debes entregar subnet_id."
    }
  }
}

#########################
# VNet Integration (opcional)
#########################
resource "azurerm_app_service_virtual_network_swift_connection" "vnet" {
  count = var.enable_vnet_integration ? 1 : 0

  app_service_id = azurerm_linux_function_app.fa.id
  subnet_id      = var.subnet_id
}
