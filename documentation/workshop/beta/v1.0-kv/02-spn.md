### <img src="../../../../documentation/SAP_Automation_on_Azure/assets/images/UnicornSAPBlack256x256.png" width="64px"> SAP Automation > V1.x.x <!-- omit in toc -->
# Bootstrapping the Deployer <!-- omit in toc -->

Master Branch's status: [![Build Status](https://dev.azure.com/azuresaphana/Azure-SAP-HANA/_apis/build/status/Azure.sap-hana?branchName=master&api-version=5.1-preview.1)](https://dev.azure.com/azuresaphana/Azure-SAP-HANA/_build/latest?definitionId=6&branchName=master)

<br/>

## Table of contents <!-- omit in toc -->

- [Overview](#overview)

<br/>

## Overview

SPN
Not on deployer
Delete old in ad
Create
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/XXXX" --name="Deployment Account-NP"
az role assignment create --assignee <appId> --role "User Access Administrator"

Add keys
az keyvault secret set --name "<ENV>-subscription-id" --vault-name "<User_KV_name>" --value "<subscription-id>";
az keyvault secret set --name "<ENV>-client-id"       --vault-name "<User_KV_name>" --value "<appId>";
az keyvault secret set --name "<ENV>-client-secret"   --vault-name "<User_KV_name>" --value "<password>";
az keyvault secret set --name "<ENV>-tenant-id"       --vault-name "<User_KV_name>" --value "<tenant>";


<br/><br/><br/><br/>


# Next: [Bootstrap - Library](03-bootstrap-library.md) <!-- omit in toc -->
