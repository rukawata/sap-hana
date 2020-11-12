locals {
  deployer_tfvars = {
    location                            = local.location
    deployer_vnet_address_space         = var.deployer_vnet_address_space
    deployer_subnet_prefix              = var.deployer_subnet_prefix
    deployer_rg_name                    = var.deployer_rg_name
    vnet_mgmt_arm_id                    = var.vnet_mgmt_arm_id
    vnet_mgmt_name                      = var.vnet_mgmt_name
    sub_mgmt_arm_id                     = var.sub_mgmt_arm_id
    sub_mgmt_name                       = var.sub_mgmt_name
    sub_mgmt_nsg_arm_id                 = var.sub_mgmt_nsg_arm_id
    sub_mgmt_nsg_name                   = var.sub_mgmt_nsg_name
    sub_mgmt_nsg_allowed_ips            = var.sub_mgmt_nsg_allowed_ips
    deployer_size                       = var.deployer_size
    deployer_disk_type                  = var.deployer_disk_type
    deployer_os_source_image_id         = var.deployer_os_source_image_id
    deployer_os                         = var.deployer_os
    deployer_authentication_type        = var.deployer_authentication_type
    deployer_authentication_username    = var.deployer_authentication_username
    deployer_authentication_password    = var.deployer_authentication_password
    deployer_sshkey_path_to_public_key  = var.deployer_sshkey_path_to_public_key
    deployer_sshkey_path_to_private_key = var.deployer_sshkey_path_to_private_key
    deployer_private_ip_address         = var.deployer_private_ip_address
    enable_secure_transfer              = var.enable_secure_transfer
  }
}

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
