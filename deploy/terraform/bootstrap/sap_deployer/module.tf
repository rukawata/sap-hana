/*
Description:

  Example to deploy deployer(s) using local backend.
*/
module "sap_deployer" {
  source         = "../../terraform-units/modules/sap_deployer"
  infrastructure = var.infrastructure
  deployers      = var.deployers
  options        = var.options
  ssh-timeout    = var.ssh-timeout
  sshkey         = var.sshkey
  naming         = module.sap_namegenerator.naming
  // tfvar interface
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

module "sap_namegenerator" {
  source               = "../../terraform-units/modules/sap_namegenerator"
  environment          = local.environment
  location             = local.location
  codename             = local.codename
  management_vnet_name = local.vnet_mgmt_name_part
  random_id            = module.sap_deployer.random_id
  deployer_vm_count    = local.deployer_vm_count
}
