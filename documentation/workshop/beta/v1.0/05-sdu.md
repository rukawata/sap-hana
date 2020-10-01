### <img src="../../../../documentation/assets/UnicornSAPBlack256x256.png" width="64px"> SAP Automation > V1.x.x <!-- omit in toc -->
# SDU - SAP Deployment Unit <!-- omit in toc -->

Master Branch's status: [![Build Status](https://dev.azure.com/azuresaphana/Azure-SAP-HANA/_apis/build/status/Azure.sap-hana?branchName=master&api-version=5.1-preview.1)](https://dev.azure.com/azuresaphana/Azure-SAP-HANA/_build/latest?definitionId=6&branchName=master)

<br>

## Table of contents <!-- omit in toc -->

- [Overview](#overview)
- [Procedure](#procedure)
  - [SDU - SAP Deployment Unit](#sdu---sap-deployment-unit)


<br>

## Overview

|                  |              |
| ---------------- | ------------ |
| Duration of Task | `5 minutes`  |
| Steps            | `6`          |
| Runtime          | `10 minutes`  |

---

<br/><br/>

## Procedure

### SDU - SAP Deployment Unit

<br/>

1. Create Working Directory.
    ```bash
    mkdir -p ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_SYSTEM/NP-EUS2-SAP0-X00; cd $_
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
    key                   = "NP-EUS2-SAP0-X00.terraform.tfstate"
    EOF
    ```

<br>

1. Create input parameter [JSON](templates/NP-EUS2-SAP0-X00.json)
    ```bash
    vi NP-EUS2-SAP0-X00.json
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
       terraform plan  --var-file=NP-EUS2-SAP0-X00.json                                \
                       ../../../sap-hana/deploy/terraform/run/sap_system/
       ```

    3. Apply
       <br/>
       ```bash
       terraform apply --auto-approve                                                  \
                       --var-file=NP-EUS2-SAP0-X00.json                                \
                       ../../../sap-hana/deploy/terraform/run/sap_system/
       ```

<br/>


<br/><br/><br/><br/>
