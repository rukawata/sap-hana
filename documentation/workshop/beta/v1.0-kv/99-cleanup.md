#        1         2         3         4         5         6         7         8
# 345678901234567890123456789012345678901234567890123456789012345678901234567890
#--------------------------------------+---------------------------------------8
#                                                                              |
#                                   DESTROY                                    |
#                                     ALL                                      |
#                                                                              |
#--------------------------------------+---------------------------------------8

# Duration of Task      : 12 minutes


cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_SYSTEM/NP-EUS2-SAP0-X00
terraform destroy --auto-approve                                                        \
                  --var-file=NP-EUS2-SAP0-X00.json                                      \
                  ../../../sap-hana/deploy/terraform/run/sap_system/


cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_SYSTEM/NP-EUS2-SAP0-X01
terraform destroy --auto-approve                                                        \
                  --var-file=NP-EUS2-SAP0-X01.json                                      \
                  ../../../sap-hana/deploy/terraform/run/sap_system/


cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_SYSTEM/NP-EUS2-SAP0-X02
terraform destroy --auto-approve                                                        \
                  --var-file=NP-EUS2-SAP0-X02.json                                      \
                  ../../../sap-hana/deploy/terraform/run/sap_system/


cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_LANDSCAPE/NP-EUS2-SAP0-INFRASTRUCTURE
terraform destroy --auto-approve                                                        \
                  --var-file=NP-EUS2-SAP0-INFRASTRUCTURE.json                           \
                  ../../../sap-hana/deploy/terraform/run/sap_system/
