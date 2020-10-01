### <img src="../../../../documentation/assets/UnicornSAPBlack256x256.png" width="64px"> SAP Automation > V1.x.x <!-- omit in toc -->
# Logical SAP Workload VNET <!-- omit in toc -->

Master Branch's status: [![Build Status](https://dev.azure.com/azuresaphana/Azure-SAP-HANA/_apis/build/status/Azure.sap-hana?branchName=master&api-version=5.1-preview.1)](https://dev.azure.com/azuresaphana/Azure-SAP-HANA/_build/latest?definitionId=6&branchName=master)

<br>

## Table of contents <!-- omit in toc -->

- [Overview](#overview)
- [Procedure](#procedure)
  - [Logical SAP Workload VNET](#logical-sap-workload-vnet)

<br>

## Overview

![Block4](assets/Block4.png)
|                  |              |
| ---------------- | ------------ |
| Duration of Task | `5 minutes`  |
| Steps            | `6`          |
| Runtime          | `1 minutes`  |

---

<br/><br/>

## Procedure

### Logical SAP Workload VNET

<br/>

1. Create Working Directory.
    ```bash
    mkdir -p ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_LANDSCAPE/NP-EUS2-SAP0-INFRASTRUCTURE; cd $_
    ```

<br>

2. Reuse SSH Keys.
    ```bash
    cp ../../LOCAL/NP-EUS2-DEP00-INFRASTRUCTURE/sshkey* .
    ```

<br>

3. Extract Storage Account name
   ```bash
   egrep -wi 'storage_account_name'                                                    \
     ../../SAP_LIBRARY/NP-EUS2-SAP_LIBRARY/.terraform/terraform.tfstate |              \
     sed -e 's/^[ \t]*//' | grep -m 1 -i tfstate
   ```

<br>

4. Create *backend* parameter file.
   <br/>Update with Storage Account name for TFSTATE, identified in previous step.
    ```bash
    cat <<EOF > backend
    resource_group_name   = "NP-EUS2-SAP_LIBRARY"
    storage_account_name  = "REPLACE_WITH_TFSTATE_STORAGE_ACCOUNT_NAME"
    container_name        = "tfstate"
    key                   = "NP-EUS2-SAP0-INFRASTRUCTURE.terraform.tfstate"
    EOF
    ```

<br>

5. Create input parameter [JSON](templates/NP-EUS2-SAP0-INFRASTRUCTURE.json)
    ```bash
    vi NP-EUS2-SAP0-INFRASTRUCTURE.json
    ```

<br>

6. Terraform
    1. Initialization
       ```bash
       terraform init  --backend-config backend                                        \
                       ../../../sap-hana/deploy/terraform/run/sap_system/
       ```

    2. Plan
       ```bash
       terraform plan  --var-file=NP-EUS2-SAP0-INFRASTRUCTURE.json                     \
                       ../../../sap-hana/deploy/terraform/run/sap_system/
       ```

    3. Apply
       <br/>
       ```bash
       terraform apply --auto-approve                                                  \
                       --var-file=NP-EUS2-SAP0-INFRASTRUCTURE.json                     \
                       ../../../sap-hana/deploy/terraform/run/sap_system/
       ```

<br/>


<br/><br/><br/><br/>

# Next: [SAP Deployment Unit - SDU](05-sdu.md) <!-- omit in toc -->
