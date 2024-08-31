### credentials 

variable "tenant_id" {
  type    = string
  default = "set_tenant_id"
}

variable "subscription_id" {
  type    = string
  default = "set_subscription_id"
}

# variable "azurerm_client_id" {}

# variable "azurerm_client_secret" {}

### project settings 

variable "project_short_name" {
  type    = string
  default = "bsh"
}

variable "application_short_name" {
  type    = string
  default = "tst"
}

variable "owner" {
  type = string
}

variable "location" {
  type    = string
  default = "WestEurope"
}

variable "locatio_short_name" {
  type    = string
  default = "we"
}

### network

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  type        = list(string)
  default     = ["10.0.0.0/18"]
  description = "range 10.0.0.1 - 10.0.63.254 = 16.384"
}

### VM config

variable "virtual_machines" {
  description = "virtual_machines"
  type = list(object({
    flavor = string
    image  = string
  }))
  default = []
  validation {
    condition     = length(var.virtual_machines) >= 2 && length(var.virtual_machines) <= 100    
    error_message = "VM list needs to be between 2 and 100"
  }

  validation {
    condition = alltrue([for vm in var.virtual_machines : contains(["ubuntu20", "ubuntu22"], vm.image)])
    error_message = <<EOM
Unsupported virtual_machines.image recieved, allowed images are 'ubuntu20', 'ubuntu22'
Please check input 'virtual_machines.image'
EOM
  }
}

