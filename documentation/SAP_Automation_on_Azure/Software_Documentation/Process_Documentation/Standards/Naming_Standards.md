### <img src="../../../assets/images/UnicornSAPBlack256x256.png" width="64px"> SAP Automation <!-- omit in toc -->
## Automated SAP Deployments in Azure Cloud <!-- omit in toc -->


Naming Conventions for
SAP Automation

 
SAP Automation
Naming Conventions
Version 1.0
 
Revision History
| Date       | Version | Description                              | Author           |
| ---------- | :-----: | ---------------------------------------- | ---------------- |
| 02/07/2020 | 0.1     |                                          | Morgan Deegan 🦄 |
| 02/11/2020 | 0.2     | Add examples, descriptions, and Glossary | Morgan Deegan 🦄 |
| 02/14/2020 | 0.3     | Add examples, descriptions, and Glossary | Morgan Deegan 🦄 |
| 07/09/2020 | 0.4     | Changes from Naming Convention Meeting   | Morgan Deegan 🦄 |
| 09/01/2020 | 1.0     | Finalized Draft                          | Morgan Deegan 🦄 |
   
   
   
   
 
Table of Contents
1 Naming Standards 5
1.1 Terraform 5
1.2 Concepts 5
1.2.1 ENVIRONMENT 5
1.2.2 SAP_VNET 5
1.2.3 CODENAME 5
1.3 Conventions 5
1.3.1 Key 5
1.3.2 DEPLOYER 6
1.3.3 SAP_LIBRARY 6
1.3.4 SAP_VNET 8
1.3.5 SDU 8
1.3.6 Region Mapping 11
2 TAGS 13
3 Appendix 14
3.1 Definitions, acronyms, and abbreviations 14

 
# 1 Naming Standards
## 1.1 Terraform
The objective in the naming convention is to provide a descriptive naming scheme while also allowing for logical partitioning.
- Allow for the SAP_VNET Infrastructure to be deployed into any supported region.
- Allow for multiple deployments of the SAP_VNET Infrastructure into the same region. This creates a Partitioning of the SAP_VNETS.
- Allow the SDU to be deployed into any SAP_VNET to support SA, HA, DR, and Fall-Forward.
<br/><br/>

## 1.2 Concepts

### 1.2.1 ENVIRONMENT
Logical boundary for the environment. (ex. PROTOTYPE, SANDBOX, NONPROD, PROD). This introduces the concept of Partitioning or Blast Radius Containment. Terraform could have credentials/RBAC to provision exclusively within a subscription, and NOT have the credentials/RBAC to provision into other environments. The naming convention allows this to be collapsed to a single subscription, but that is not the preferred model.
<br/><br/>

### 1.2.2 SAP_VNET
Logical partitioning of VNETs. This is the support for more than one VNET within a region.
<br/><br/>

### 1.2.3 CODENAME
Logical partitioning of development cycles or projects.
<br/><br/>

## 1.3 Conventions

### 1.3.1 Key

| Key         | Legnth   | Description                   |
| ----------- | -------- | ----------------------------- |
| ENVIRONMENT | (5 CHAR) | SND, PROTO, NP, PROD          |
| REGION_MAP  | (4 CHAR) | Representation of region.     |
| SAP_VNET    | (7 CHAR) | Logical VNET Name (Ex: SAP0)  |
| CODENAME    |          | A Logical name assigned to a development effort. This would allow old and new versions of identical resources to coexist in the dev environment. Or it is just a fun name for your deployment. |
<br/><br/>

## 1.3.2 DEPLOYER

| DEPLOYER         | Max Char     | Example                       |
| ---------------  | -----------: | ----------------------------- |
| Resource Group   | 80           | `{ENVIRONMENT}-{REGION_MAP}-{DEPLOY_VNET}-INFRASTRUCTURE`<br/>Ex: PROTO-WUS2-DEPLOY-INFRASTRUCTURE               |
| VNET             | 38<br/>(64)  | `{ENVIRONMENT}-{REGION_MAP}-{DEPLOY_VNET}-vnet`                                                                  |
| Subnet           | 80           | `{ENVIRONMENT}-{REGION_MAP}-{DEPLOY_VNET}_deployment-subnet`                                                     |
| Storage Account  | 24           | `{environment(5CHAR)}{region_map(4CHAR)}{sap_vnet(7CHAR)}diag(5CHAR){RND(3CHAR)}`<br/>Ex: protowus2deploydiagxxx |
| NSG              | 80           | `{ENVIRONMENT}-{REGION_MAP}-{DEPLOY_VNET}_deployment-nsg`                                                        |
| Route Table      |              | `{ENVIRONMENT}-{REGION_MAP}-{DEPLOY_VNET}_routeTable`                                                            |
| UDR              |              | `{remote_vnet}_Hub-udr`                                                                                          |
| NIC              | 80           | `{ENVIRONMENT}-{REGION_MAP}-{DEPLOY_VNET}_{computername}-nic`<br/>No naming convention needed for ip_configuration block.<br/>Ex: name =ipconfig1
| Disk             |              | `{vm.name}-deploy00`<br/>Code: `${azurerm_virtual_machine.iscsi.*.name}-iscsi00`<br/>Ex: PROTO-WUS2-DEPLOY_deploy00-deploy00
| VM               | 80           | `{ENVIRONMENT}-{REGION_MAP}-{DEPLOY_VNET}_{computername}`
| OS Disk          |              | `{ENVIRONMENT}-{REGION_MAP}-{DEPLOY_VNET}_{computername}-OsDisk`
| Computer Name    |              | `{environment[_map]}{region_map}{deploy_vnet}deploy##`
| Managed Identity |              | `{ENVIRONMENT}-{REGION_MAP}-{DEPLOY_VNET}-msi`
| Key Vault        | 24           | `{ENVIRONMENT(5char)}{REGION_MAP(4CHAR)}{DEPLOY_VNET(7CHAR)}prvt{RND(3CHAR)}`<br/>`{ENVIRONMENT(5char)}{REGION_MAP(4CHAR)}{DEPLOY_VNET(7CHAR)}user{RND(3CHAR)}`
| Public IP        |              | `{ENVIRONMENT}-{REGION_MAP}-{DEPLOY_VNET}_{computername}-pip`
<br/><br/>

## 1.3.3 SAP_LIBRARY

| SAP_LIBRARY      | Max Char     | Example                       |
| ---------------  | -----------: | ----------------------------- |
| Resource Group   | 80           | `{ENVIRONMENT}-{REGION_MAP}-SAP_LIBRARY`<br/>Ex: PROTO-WUS2-SAP_LIBRARY
| Storage Account  | 24           | `{environment(5char)}{region_map(4CHAR)}saplib(12CHAR){RND(3CHAR)}`<br/>Ex: protowus2saplibxxx
| Key Vault        | 24           | `{ENVIRONMENT(5char)}{REGION_MAP(4CHAR)}SAPLIBprvt(12CHAR){RND(3CHAR)}`<br>`{ENVIRONMENT(5char)}{REGION_MAP(4CHAR)}SAPLIBuser(12CHAR){RND(3CHAR)}`
<br/><br/>


## 1.3.4 SAP_VNET

| SAP_VNET         | Max Char     | Example                       |
| ---------------  | -----------: | ----------------------------- |
| Resource Group   | 80           | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}-INFRASTRUCTURE`<br/>Ex: PROTO-WUS2-SAP0-INFRASTRUCTURE
| VNET             | 38<br/>(64)  | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}-vnet`
| Peering          | 80           | `{local_vnet_name}_to_{remote_vnet_name}`
| Subnet           | 80           | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_utility-subnet`
| Storage Account  | 24           | `{environment(5char)}{region_map(4CHAR)}{sap_vnet(7CHAR)}diag(5CHAR){RND(3CHAR)}`<br/>Ex: protowus2sap0diagxxx
| NSG              | 80           | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_iscsi-nsg`
| Route Table      |              | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_routeTable`
| UDR              |              | `{remote_vnet}_Hub-udr`
| AVSET            |              | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_iscsi-avset`
| NIC              | 80           | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_iscsi##-nic`
| Disk             |              | `{vm.name}-iscsi00`<br/>Code: `${azurerm_virtual_machine.iscsi.*.name}-iscsi00`<br/>Ex: PROTO-WUS2-SAP0_iscsi00-iscsi00
| VM               |              | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_iscsi##`
| OS Disk          |              | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_iscsi##-OsDisk`
| Computer Name    |              | `{environment[_map]}{sap_vnet}{region_map}iscsi##`
| Key Vault        | 24           | `{ENVIRONMENT(5char)}{REGION_MAP(4CHAR)}{SAP_VNET(7CHAR)}prvt(5CHAR){RND(3CHAR)}`<br/>`{ENVIRONMENT(5char)}{REGION_MAP(4CHAR)}{SAP_VNET(7CHAR)}user(5CHAR){RND(3CHAR)}`
<br/><br/>


## 1.3.5 SDU

| SDU              | Max Char     | Example                       |
| ---------------  | -----------: | ----------------------------- |
| Resource Group   | 80           | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}`<br/>Ex: PROTO-WUS2_S4DEV-Z00
| PPG              |              | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_ppg`
| Subnet           | 80           | `{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_app-subnet`
| NSG 80 NIC Level:
{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_app-nsg

Subnet Level:
{ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_appSubnet-nsg
| AVSET  {ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_app-avset
| NIC 80 {ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_{vm.name}-{sub}-nic

Ex: _{vm.name}-app-nic
Ex: _{vm.name}-web-nic
Ex: _{vm.name}-admin-nic
Ex: _{vm.name}-db-nic
| Disk  {vm.name}-sap00
{vm.name}-data00
{vm.name}-log00
{vm.name}-backup00

Code: ${element(azurerm_virtual_machine.app.*.name, count.index)}-sap00
| VM 80 {ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_{computername}
| OS Disk  {ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_{computername}-osDisk
| Computer Name
Two naming standards:
• DB
• Non-DB 14 {sapsid}app##[l|w]{RND(3CHAR)}
Code:  ${lower(var._sap_sid)}app${format("%02d", count.index)}

{sapsid}d{dbsid}##[l|w]{nodeNumber(1CHAR)}{RND(3CHAR)}


Ex: z00app00labc
Ex: z00scs00wabc
Ex: z00web00labc

Ex: z00dhdb00l0abc
Ex: z00dora00l0abc

14< Char SAP Specific
| ALB 80 {ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_db-alb
| ALB Backend Pool  {ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_dbAlb-bePool
| ALB Rule 80 {ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_dbAlb-rule_port-01
 Key Vault 24 {ENVIRONMENT(5CHAR)}{REGION_MAP(4CHAR)}{SAP_VNET(7CHAR)}SIDp(5CHAR){RND(3CHAR)}

{ENVIRONMENT(5CHAR)}{REGION_MAP(4CHAR)}{SAP_VNET(7CHAR)}SIDu(5CHAR){RND(3CHAR)}
 Front end IP  {ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_dbAlb-feip

 Health Probe  {ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}_{CODENAME}-{SID}_dbAlb-hp?
• app or hdb can be replaced with an identifier. (ex. app, db, scs, web)
• Numbering starts at 0
• Numbers formatted for two characters (ex. 00)
<br/><br/>


1.3.6 Region Mapping

1.3.6.1 Example: Variable Definition
```
variable "_region_mapping" {
                              type        = map(string)
                              description = "Region Mapping: Full = Single CHAR, 4-CHAR"

  # 28 Regions
  default = {
                              westus              = "weus"
                              westus2             = "wus2"
                              centralus           = "ceus"
                              eastus              = "eaus"
                              eastus2             = "eus2"
                              northcentralus      = "ncus"
                              southcentralus      = "scus"
                              westcentralus       = "wcus"
                              northeurope         = "noeu"
                              westeurope          = "weeu"
                              eastasia            = "eaas"
                              southeastasia       = "seas"
                              brazilsouth         = "brso"
                              japaneast           = "jpea"
                              japanwest           = "jpwe"
                              centralindia        = "cein"
                              southindia          = "soin"
                              westindia           = "wein"
                              uksouth2            = "uks2"
                              uknorth             = "ukno"
                              canadacentral       = "cace"
                              canadaeast          = "caea"
                              australiaeast       = "auea"
                              australiasoutheast  = "ause"
                              uksouth             = "ukso"
                              ukwest              = "ukwe"
                              koreacentral        = "koce"
                              koreasouth          = "koso"
  }
}
```


1.3.6.2 Example Usage:
```
  # naming standard       = {ENVIRONMENT}-{REGION_MAP}-{SAP_VNET}-INFRASTRUCTURE
  name                    = "${upper(var.__environment)}-${
                               upper(element(split(",", lookup(var.__region_mapping, var.__region, "-,unknown")),1))}-${
                               upper(var.__sap_vnet)}-INFRASTRUCTURE"
```


 
## 2 TAGS
<br/>
Notes:
Track

<br/><br/>

## 3 Appendix
<br/>

### 3.1 Definitions, acronyms, and abbreviations
<br/>

| Term         | Description                                     |
| ------------ | ----------------------------------------------- |
| ALB          | Azure Load Balancer                             |
| AVSET        | Azure Availability Set                          |
| B&D          | Build and Destroy, alternate term, Fall-Forward |
| DR           | Disaster Recovery                               |
| Fall-Forward | See B&D                                         |
| HA           | High-Availability                               |
| NIC          | Network Interface Component                     |
| NSG          | Network Security Group                          |
| SA           | Stand-Alone                                     |
| SDU          | SAP Deployment Unit                             |
| UDR          | User Defined Route                              |
| VM           | Virtual Machine                                 |
| VNET         | Virtual Network                                 |
 
