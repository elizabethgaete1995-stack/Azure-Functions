############################
# Tags estándar (obligatorio)
############################
variable "entity" { type = string }
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "pre", "pro"], lower(var.environment))
    error_message = "environment debe ser: dev, pre o pro."
  }
}
variable "app_name" { type = string }
variable "cost_center" { type = string }
variable "tracking_code" { type = string }

variable "custom_tags" {
  type    = map(string)
  default = {}
}

variable "inherit" {
  type    = bool
  default = true
}
############################################
# Resource Group / Location / Subscription
############################################
variable "rsg_name" {
  description = "Nombre del Resource Group donde se despliega."
  type        = string
}

variable "location" {
  description = "Azure region donde se despliega (ej: eastus2, brazilsouth)."
  type        = string
}

variable "subscriptionid" {
  description = "Subscription ID destino."
  type        = string
}

variable "tenantid" {
  description = "Tenant ID destino."
  type        = string
}

############################
# Básicos
############################

# Nombre final: si viene null/empty, se genera con {entity}-{environment}-{app_name}-func-01
variable "function_app_name" {
  type        = string
  default     = null
  description = "Nombre de la Function App. Si null/empty, se genera con el estándar."
}

variable "name_suffix" {
  type    = string
  default = "func-01"
}

############################
# Service Plan
############################
variable "plan_name" {
  type        = string
  default     = null
  description = "Nombre del Service Plan. Si null, se genera."
}

variable "plan_sku_name" {
  type        = string
  default     = "Y1"
  description = "SKU del plan. Ejemplos: Y1 (Consumption), EP1 (Premium), P1v3 (Dedicated)."
}

variable "plan_os_type" {
  type        = string
  default     = "Linux"
  description = "Linux o Windows (para el service plan)."
  validation {
    condition     = contains(["Linux", "Windows"], var.plan_os_type)
    error_message = "plan_os_type debe ser Linux o Windows."
  }
}

############################
# Storage Account (requerido)
############################
variable "storage_account_name" {
  type        = string
  default     = null
  description = "Nombre del Storage Account. Si null, se genera."
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_replication_type" {
  type    = string
  default = "LRS"
}

############################
# Runtime (Linux)
############################
variable "functions_extension_version" {
  type    = string
  default = "~4"
}

variable "application_stack" {
  description = "Stack de runtime para Linux Function App."
  type = object({
    node_version   = optional(string)
    dotnet_version = optional(string)
    java_version   = optional(string)
    python_version = optional(string)
  })
  default = {}
}

variable "https_only" {
  type    = bool
  default = true
}

variable "always_on" {
  type        = bool
  default     = false
  description = "Recomendado true para Premium/Dedicated; en Consumption no aplica igual."
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

############################
# Identity (opcional)
############################
variable "identity_type" {
  type    = string
  default = "SystemAssigned"
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned", "None"], var.identity_type)
    error_message = "identity_type debe ser: None, SystemAssigned, UserAssigned o 'SystemAssigned, UserAssigned'."
  }
}

variable "user_assigned_identity_ids" {
  type    = list(string)
  default = []
}

############################
# VNet Integration (opcional)
############################
variable "enable_vnet_integration" {
  type    = bool
  default = false
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID para swift integration."
}

############################
# App Insights (opcional pero recomendado)
############################
variable "enable_app_insights" {
  type    = bool
  default = true
}

variable "app_insights_name" {
  type    = string
  default = null
}

variable "app_insights_type" {
  type    = string
  default = "web"
}
