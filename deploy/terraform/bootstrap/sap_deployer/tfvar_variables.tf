// tfvar variables
variable "deployer_rg_name" {
  default = ""
}

variable "environment" {
  type        = string
  description = ""

  validation {
    condition     = length(var.environment) > 0 && length(var.environment) < 5
    error_message = "Please enter a valid enviorment."
  }
}

variable "location" {
  type        = string
  description = ""

  validation {
    condition     = length(var.location) > 0
    error_message = "Please enter a valid enviorment."
  }
}

variable "codename" {
  type    = string
  default = ""
}

variable "deployer_vnet_address_space" {
}

variable "deployer_subnet_prefix" {
}

variable "vnet_mgmt_name" {
  default = ""
}

variable "vnet_mgmt_arm_id" {
  default = ""
}

variable "sub_mgmt_name" {
  default = ""
}

variable "sub_mgmt_arm_id" {
  default = ""
}

variable "sub_mgmt_nsg_arm_id" {
  default = ""
}

variable "sub_mgmt_nsg_name" {
  default = ""
}

variable "sub_mgmt_nsg_allowed_ips" {
  default = []
}

variable "deployer_size" {
  default = "Standard_D2s_v3"
}

variable "deployer_disk_type" {
  default = "StandardSSD_LRS"
}

variable "deployer_os_source_image_id" {
  default = ""
}

variable "deployer_os" {
  default = {
    "publisher" = "Canonical"
    "offer"     = "UbuntuServer"
    "sku"       = "18.04-LTS"
    "version"   = "latest"
  }
}

variable "deployer_authentication_type" {
  default = "key"
}

variable "deployer_authentication_username" {
  default = "azureadm"
}
variable "deployer_authentication_password" {
  default = ""
}

variable "deployer_sshkey_path_to_public_key" {
  default = ""
}

variable "deployer_sshkey_path_to_private_key" {
  default = ""
}

variable "deployer_private_ip_address" {
  default = []
}

variable "enable_secure_transfer" {
  default = true
}
