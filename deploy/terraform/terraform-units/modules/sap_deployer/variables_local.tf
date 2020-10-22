/*
Description:

  Define local variables.
*/
variable naming {
  description = "naming convention"
}

// Set defaults
locals {

  storageaccount_names = var.naming.storageaccount_names.DEPLOYER
  virtualmachine_names = var.naming.virtualmachine_names.DEPLOYER
  keyvault_names       = var.naming.keyvault_names.DEPLOYER
  resource_suffixes    = var.naming.resource_suffixes

  // Default option(s):
  enable_secure_transfer = try(var.options.enable_secure_transfer, true)

  // Resource group and location

  region  = try(var.infrastructure.region, "")
  prefix  = try(var.infrastructure.resource_group.name, var.naming.prefix.DEPLOYER)
  rg_name = try(var.infrastructure.resource_group.name, format("%s%s", local.prefix, local.resource_suffixes.deployer-rg))

  // Management vnet
  vnet_mgmt        = try(var.infrastructure.vnets.management, {})
  vnet_mgmt_arm_id = try(local.vnet_mgmt.arm_id, "")
  vnet_mgmt_exists = length(local.vnet_mgmt_arm_id) > 0 ? true : false
  vnet_mgmt_name   = local.vnet_mgmt_exists ? split("/", local.vnet_mgmt_arm_id)[8] : format("%s%s", local.prefix, local.resource_suffixes.vnet)
  vnet_mgmt_addr   = local.vnet_mgmt_exists ? "" : try(local.vnet_mgmt.address_space, "10.0.0.0/24")

  // Management subnet
  sub_mgmt          = try(local.vnet_mgmt.subnet_mgmt, {})
  sub_mgmt_arm_id   = try(local.sub_mgmt.arm_id, "")
  sub_mgmt_exists   = length(local.sub_mgmt_arm_id) > 0 ? true : false
  sub_mgmt_name     = local.sub_mgmt_exists ? split("/", local.sub_mgmt_arm_id)[10] : try(local.sub_mgmt.name, format("%s%s", local.prefix, local.resource_suffixes.deployer-subnet))
  sub_mgmt_prefix   = local.sub_mgmt_exists ? "" : try(local.sub_mgmt.prefix, "10.0.0.16/28")
  sub_mgmt_deployed = try(local.sub_mgmt_exists ? data.azurerm_subnet.subnet_mgmt[0] : azurerm_subnet.subnet_mgmt[0], null)

  // Management NSG
  sub_mgmt_nsg             = try(local.sub_mgmt.nsg, {})
  sub_mgmt_nsg_arm_id      = try(local.sub_mgmt_nsg.arm_id, "")
  sub_mgmt_nsg_exists      = length(local.sub_mgmt_nsg_arm_id) > 0 ? true : false
  sub_mgmt_nsg_name        = local.sub_mgmt_nsg_exists ? "" : try(local.sub_mgmt_nsg.name, format("%s_deploymentSubnet-nsg", local.prefix))
  sub_mgmt_nsg_allowed_ips = local.sub_mgmt_nsg_exists ? [] : try(local.sub_mgmt_nsg.allowed_ips, ["0.0.0.0/0"])
  sub_mgmt_nsg_deployed    = try(local.sub_mgmt_nsg_exists ? data.azurerm_network_security_group.nsg_mgmt[0] : azurerm_network_security_group.nsg_mgmt[0], null)

  // Deployer(s) information from input
  deployer_input = var.deployers

  // Deployer(s) information with default override
  enable_deployers = length(local.deployer_input) > 0 ? true : false

  // Provide the ability to deploy without the VM
  enable_vm        = try(local.deployer_input.deploy_vm, true)

  // Deployer(s) authentication method with default
  enable_password = contains(compact([
    for deployer in local.deployer_input :
    try(deployer.authentication.type, "key") == "password" ? true : false
  ]), "true")

  // By default use generated password. Provide password under authentication overides it
  input_pwd_list = compact([
    for deployer in local.deployer_input :
    try(deployer.authentication.password, "")
  ])
  input_pwd = length(local.input_pwd_list) > 0 ? local.input_pwd_list[0] : null
  password  = (local.enable_deployers && local.enable_password) ? try(local.input_pwd_list[0], random_password.deployer[0].result) : null

  enable_key = contains(compact([
    for deployer in local.deployer_input :
    try(deployer.authentication.type, "key") == "key" ? true : false
  ]), "true")

  // By default use generated public key. Provide sshkey.path_to_public_key and path_to_private_key overides it
  public_key  = (local.enable_deployers && local.enable_key) ? try(file(var.sshkey.path_to_public_key), tls_private_key.deployer[0].public_key_openssh) : null
  private_key = (local.enable_deployers && local.enable_key) ? try(file(var.sshkey.path_to_private_key), tls_private_key.deployer[0].private_key_pem) : null

  deployers = [
    for idx, deployer in local.deployer_input : {
      "name"                 = local.virtualmachine_names[idx],
      "destroy_after_deploy" = true,
      "size"                 = try(deployer.size, "Standard_D2s_v3"),
      "disk_type"            = try(deployer.disk_type, "StandardSSD_LRS")
      "os" = {
        "source_image_id" = try(deployer.os.source_image_id, "")
        "publisher"       = try(deployer.os.source_image_id, "") == "" ? "Canonical" : ""
        "offer"           = try(deployer.os.source_image_id, "") == "" ? "UbuntuServer" : ""
        "sku"             = try(deployer.os.source_image_id, "") == "" ? "18.04-LTS" : ""
        "version"         = try(deployer.os.source_image_id, "") == "" ? "latest" : ""
      },
      "authentication" = {
        "type"     = try(deployer.authentication.type, "key")
        "username" = try(deployer.authentication.username, "azureadm")
        "sshkey" = {
          "public_key"  = local.public_key
          "private_key" = local.private_key
        }
        "password" = local.password
      },
      "components" = [
        "terraform",
        "ansible"
      ],
      "private_ip_address" = try(deployer.private_ip_address, cidrhost(local.sub_mgmt_deployed.address_prefixes[0], idx + 4)),
      "users" = {
        "object_id" = try(deployer.users.object_id, [])
      }
    }
  ]

  // Deployer(s) information with updated pip
  deployers_updated = [
    for idx, deployer in local.deployers : merge({
      "public_ip_address" = azurerm_public_ip.deployer[idx].ip_address
    }, deployer)
  ]

  // This is to be aligned with sap_library design.
  // If no additonal user going to be supported, this part needs to be changed.
  deployer_users_id = distinct(
    flatten([
      for deployer in local.deployers :
      deployer.users.object_id
    ])
  )

  // public ip address list of deployers
  deployer_public_ip_address_list = distinct(flatten([
    for pip_deployer in azurerm_public_ip.deployer :
    pip_deployer.ip_address
  ]))

  // public ip address of the first deployer
  deployer_public_ip_address = local.enable_deployers ? local.deployer_public_ip_address_list[0] : ""

  // Comment out code with users.object_id for the time being.
  // deployer_users_id_list = distinct(compact(concat(local.deployer_users_id)))
}
