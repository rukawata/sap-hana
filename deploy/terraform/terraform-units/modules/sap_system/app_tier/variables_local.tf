variable "resource-group" {
  description = "Details of the resource group"
}

variable "subnet-mgmt" {
  description = "Details of the management subnet"
}

variable "vnet-sap" {
  description = "Details of the SAP VNet"
}

variable "storage-bootdiag" {
  description = "Details of the boot diagnostic storage device"
}

variable "ppg" {
  description = "Details of the proximity placement group"
}

variable naming {
  description = "Defines the names for the resources"
}

// Set defaults
locals {

  app_virtualmachine_names = var.naming.virtualmachine_names["APP"]
  scs_virtualmachine_names = var.naming.virtualmachine_names["SCS"]
  web_virtualmachine_names = var.naming.virtualmachine_names["WEB"]
  resource_suffixes        = var.naming.resource_suffixes

  region  = try(var.infrastructure.region, "")
  sid     = upper(try(var.application.sid, ""))
  prefix  = try(var.infrastructure.resource_group.name, var.naming.prefix.SDU)
  rg_name = try(var.infrastructure.resource_group.name, format("%s%s", local.prefix, local.resource_suffixes.sdu-rg))

  # SAP vnet
  var_infra       = try(var.infrastructure, {})
  var_vnet_sap    = try(local.var_infra.vnets.sap, {})
  vnet_sap_arm_id = try(local.var_vnet_sap.arm_id, "")
  vnet_sap_exists = length(local.vnet_sap_arm_id) > 0 ? true : false
  vnet_sap_name   = local.vnet_sap_exists ? try(split("/", local.vnet_sap_arm_id)[8], "") : try(local.var_vnet_sap.name, "")
  vnet_nr_parts   = length(split("-", local.vnet_sap_name))
  // Default naming of vnet has multiple parts. Taking the second-last part as the name 
  vnet_sap_name_prefix = local.vnet_nr_parts >= 3 ? split("-", upper(local.vnet_sap_name))[local.vnet_nr_parts - 1] == "VNET" ? split("-", local.vnet_sap_name)[local.vnet_nr_parts - 2] : local.vnet_sap_name : local.vnet_sap_name

  // APP subnet
  var_sub_app    = try(var.infrastructure.vnets.sap.subnet_app, {})
  sub_app_arm_id = try(local.var_sub_app.arm_id, "")
  sub_app_exists = length(local.sub_app_arm_id) > 0 ? true : false
  sub_app_name   = local.sub_app_exists ? try(split("/", local.sub_app_arm_id)[10], "") : try(local.var_sub_app.name, format("%s%s", local.prefix, local.resource_suffixes.app-subnet))
  sub_app_prefix = try(local.var_sub_app.prefix, "")

  // APP NSG
  var_sub_app_nsg    = try(local.var_sub_app.nsg, {})
  sub_app_nsg_arm_id = try(local.var_sub_app_nsg.arm_id, "")
  sub_app_nsg_exists = length(local.sub_app_nsg_arm_id) > 0 ? true : false
  sub_app_nsg_name   = local.sub_app_nsg_exists ? try(split("/", local.sub_app_nsg_arm_id)[8], "") : try(local.var_sub_app_nsg.name, format("%s%s", local.prefix, local.resource_suffixes.app-subnet-nsg))

  // WEB subnet
  #If subnet_web is not specified deploy into app subnet
  sub_web_defined = try(var.infrastructure.vnets.sap.subnet_web, null) == null ? false : true
  sub_web         = try(var.infrastructure.vnets.sap.subnet_web, {})
  sub_web_arm_id  = try(local.sub_web.arm_id, "")
  sub_web_exists  = length(local.sub_web_arm_id) > 0 ? true : false
  sub_web_name    = local.sub_web_exists ? try(split("/", local.sub_web_arm_id)[10], "") : try(local.sub_web.name, format("%s%s", local.prefix, local.resource_suffixes.web-subnet))
  sub_web_prefix  = try(local.sub_web.prefix, "")
  sub_web_deployed = try(local.sub_web_defined ? (
    local.sub_web_exists ? data.azurerm_subnet.subnet-sap-web[0] : azurerm_subnet.subnet-sap-web[0]) : (
  local.sub_app_exists ? data.azurerm_subnet.subnet-sap-app[0] : azurerm_subnet.subnet-sap-app[0]), null)

  // WEB NSG
  sub_web_nsg        = try(local.sub_web.nsg, {})
  sub_web_nsg_arm_id = try(local.sub_web_nsg.arm_id, "") 
  sub_web_nsg_exists = length(local.sub_web_nsg_arm_id) > 0 ? true : false
  sub_web_nsg_name   = local.sub_web_nsg_exists ? try(split("/", local.sub_web_nsg_arm_id)[8], "") : try(local.sub_web_nsg.name, format("%s%s", local.prefix, local.resource_suffixes.web-subnet-nsg))
  sub_web_nsg_deployed = try(local.sub_web_defined ? (
    local.sub_web_nsg_exists ? data.azurerm_network_security_group.nsg-web[0] : azurerm_network_security_group.nsg-web[0]) : (
    local.sub_app_nsg_exists ? data.azurerm_network_security_group.nsg-app[0] : azurerm_network_security_group.nsg-app[0]), null)

  application_sid          = try(var.application.sid, "")
  enable_deployment        = try(var.application.enable_deployment, false)
  scs_instance_number      = try(var.application.scs_instance_number, "01")
  ers_instance_number      = try(var.application.ers_instance_number, "02")
  scs_high_availability    = try(var.application.scs_high_availability, false)
  application_server_count = try(var.application.application_server_count, 0)
  webdispatcher_count      = try(var.application.webdispatcher_count, 0)
  vm_sizing                = try(var.application.vm_sizing, "Default")
  app_nic_ips              = try(var.application.app_nic_ips, [])
  scs_lb_ips               = try(var.application.scs_lb_ips, [])
  scs_nic_ips              = try(var.application.scs_nic_ips, [])
  web_lb_ips               = try(var.application.web_lb_ips, [])
  web_nic_ips              = try(var.application.web_nic_ips, [])

  app_ostype = try(var.application.os.os_type, "Linux")
  app_oscode = upper(local.app_ostype) == "LINUX" ? "l" : "w"

  authentication = try(var.application.authentication,
    {
      "type"     = upper(local.app_ostype) == "LINUX" ? "key" : "password"
      "username" = "azureadm"
      "password" = "Sap@hana2019!"
  })

  // OS image for all Application Tier VMs
  // If custom image is used, we do not overwrite os reference with default value
  app_custom_image = try(var.application.os.source_image_id, "") != "" ? true : false

  app_os = {
    "source_image_id" = local.app_custom_image ? var.application.os.source_image_id : ""
    "publisher"       = try(var.application.os.publisher, local.app_custom_image ? "" : "suse")
    "offer"           = try(var.application.os.offer, local.app_custom_image ? "" : "sles-sap-12-sp5")
    "sku"             = try(var.application.os.sku, local.app_custom_image ? "" : "gen1")
    "version"         = try(var.application.os.version, local.app_custom_image ? "" : "latest")
  }

}

// Imports Disk sizing sizing information
locals {
  sizes = jsondecode(file("${path.module}/../../../../../configs/app_sizes.json"))
}

locals {
  // Subnet IP Offsets
  // Note: First 4 IP addresses in a subnet are reserved by Azure
  ip_offsets = {
    scs_lb = 4 + 1
    web_lb = local.sub_web_defined ? (4 + 1) : -2
    scs_vm = 4 + 6
    app_vm = 4 + 10
    web_vm = local.sub_web_defined ? (4 + 2) : -3
  }

  // Default VM config should be merged with any the user passes in
  app_sizing = lookup(local.sizes.app, local.vm_sizing, lookup(local.sizes.app, "Default"))

  scs_sizing = lookup(local.sizes.scs, local.vm_sizing, lookup(local.sizes.scs, "Default"))

  web_sizing = lookup(local.sizes.web, local.vm_sizing, lookup(local.sizes.web, "Default"))

  // Ports used for specific ASCS, ERS and Web dispatcher
  lb-ports = {
    "scs" = [
      3200 + tonumber(local.scs_instance_number),          // e.g. 3201
      3600 + tonumber(local.scs_instance_number),          // e.g. 3601
      3900 + tonumber(local.scs_instance_number),          // e.g. 3901
      8100 + tonumber(local.scs_instance_number),          // e.g. 8101
      50013 + (tonumber(local.scs_instance_number) * 100), // e.g. 50113
      50014 + (tonumber(local.scs_instance_number) * 100), // e.g. 50114
      50016 + (tonumber(local.scs_instance_number) * 100), // e.g. 50116
    ]

    "ers" = [
      3200 + tonumber(local.ers_instance_number),          // e.g. 3202
      3300 + tonumber(local.ers_instance_number),          // e.g. 3302
      50013 + (tonumber(local.ers_instance_number) * 100), // e.g. 50213
      50014 + (tonumber(local.ers_instance_number) * 100), // e.g. 50214
      50016 + (tonumber(local.ers_instance_number) * 100), // e.g. 50216
    ]

    "web" = [
      80,
      3200
    ]
  }

  // Ports used for ASCS, ERS and Web dispatcher NSG rules
  nsg-ports = {
    "web" = [
      {
        "priority" = "101",
        "name"     = "SSH",
        "port"     = "22"
      },
      {
        "priority" = "102",
        "name"     = "HTTP",
        "port"     = "80"
      },
      {
        "priority" = "103",
        "name"     = "HTTPS",
        "port"     = "443"
      },
      {
        "priority" = "104",
        "name"     = "sapinst",
        "port"     = "4237"
      },
      {
        "priority" = "105",
        "name"     = "WebDispatcher",
        "port"     = "44300"
      }
    ]
  }

  // Ports used for the health probes.
  // Where Instance Number is nn:
  // SCS (index 0) - 620nn
  // ERS (index 1) - 621nn
  hp-ports = [
    62000 + tonumber(local.scs_instance_number),
    62100 + tonumber(local.ers_instance_number)
  ]

  // Create list of disks per VM
  app-data-disks = flatten([
    for vm_count in range(local.application_server_count) : [
      for disk_spec in local.app_sizing.storage : {
        vm_index          = vm_count
        suffix            = format("-%s", disk_spec.name)
        disk_type         = lookup(disk_spec, "disk_type", "Premium_LRS")
        size_gb           = lookup(disk_spec, "size_gb", 512)
        caching           = lookup(disk_spec, "caching", false)
        write_accelerator = lookup(disk_spec, "write_accelerator", false)
      }
    ]
  ])

  scs-data-disks = flatten([
    for vm_count in(local.scs_high_availability ? range(2) : range(1)) : [
      for disk_spec in local.scs_sizing.storage : {
        vm_index          = vm_count
        suffix            = format("-%s", disk_spec.name)
        disk_type         = lookup(disk_spec, "disk_type", "Premium_LRS")
        size_gb           = lookup(disk_spec, "size_gb", 512)
        caching           = lookup(disk_spec, "caching", false)
        write_accelerator = lookup(disk_spec, "write_accelerator", false)
      }
    ]
  ])

  web-data-disks = flatten([
    for vm_count in range(local.webdispatcher_count) : [
      for disk_spec in local.web_sizing.storage : {
        vm_index          = vm_count
        suffix            = format("-%s", disk_spec.name)
        disk_type         = lookup(disk_spec, "disk_type", "Premium_LRS")
        size_gb           = lookup(disk_spec, "size_gb", 512)
        caching           = lookup(disk_spec, "caching", false)
        write_accelerator = lookup(disk_spec, "write_accelerator", false)
      }
    ]
  ])
}
