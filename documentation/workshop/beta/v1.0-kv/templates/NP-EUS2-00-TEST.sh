#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#--------------------------------------+---------------------------------------8
#                                                                              |
#                               BOOTSTRAP - DEP00                              |
#                                                                              |
#--------------------------------------+---------------------------------------8

# Duration of Task      : 12 minutes

az login
az account list --output=table | grep -i true
#az account set --subscription XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX or "Name"

mkdir ~/bin; cd $_
alias terraform=~/bin/terraform
wget https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip
unzip terraform_0.12.29_linux_amd64.zip


mkdir -p ~/Azure_SAP_Automated_Deployment; cd $_
git clone https://github.com/Azure/sap-hana.git

cd ~/Azure_SAP_Automated_Deployment/sap-hana
git checkout feature/keyvault
git rev-parse HEAD
# 20200929-0551   35977f5fdaf909518ad6800b9cd55c4a76220dcb

mkdir -p ~/Azure_SAP_Automated_Deployment/WORKSPACES/LOCAL/NP-EUS2-DEP00-INFRASTRUCTURE; cd $_
#ssh-keygen -q -t rsa -C "Deploy Platform" -f sshkey
mv ~/sshkey* .
chmod 600 sshkey

# save for later
az ad user show --id modeegan@microsoft.com --query objectId --out tsv 


vi NP-EUS2-DEP00-INFRASTRUCTURE.json


terraform init  ../../../sap-hana/deploy/terraform/bootstrap/sap_deployer/

terraform plan                                                                    \
                --var-file=NP-EUS2-DEP00-INFRASTRUCTURE.json                      \
                ../../../sap-hana/deploy/terraform/bootstrap/sap_deployer/

time terraform apply --auto-approve                                               \
                     --var-file=NP-EUS2-DEP00-INFRASTRUCTURE.json                 \
                     ../../../sap-hana/deploy/terraform/bootstrap/sap_deployer/

# Run Time ~ 5m

./post_deployment.sh




#--------------------------------------+---------------------------------------8
#                                                                              |
#                            BOOTSTRAP - SAP_LIBRARY                           |
#                                                                              |
#--------------------------------------+---------------------------------------8

# Duration of Task      : 5 minutes

# Prepare

cd ~/Azure_SAP_Automated_Deployment/sap-hana
git checkout feature/keyvault
git rev-parse HEAD
# 20200929-0551   35977f5fdaf909518ad6800b9cd55c4a76220dcb

#---------------------------------------+---------------------------------------8

mkdir -p ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_LIBRARY/NP-EUS2-SAP_LIBRARY; cd $_

# cat <<EOF > backend.tf
# terraform {
#   backend "local" {
#     path      = null
#     workspace = null
#   }
# }
# EOF

vi NP-EUS2-SAP_LIBRARY.json


terraform init  ../../../sap-hana/deploy/terraform/bootstrap/sap_library/

terraform plan                                                                       \
                --var-file=NP-EUS2-SAP_LIBRARY.json                                  \
                ../../../sap-hana/deploy/terraform/bootstrap/sap_library

time terraform apply                                                                 \
                     --auto-approve                                                  \
                     --var-file=NP-EUS2-SAP_LIBRARY.json                             \
                     ../../../sap-hana/deploy/terraform/bootstrap/sap_library/

# Run Time < 1m

egrep -wi 'resource_group_name|storage_account_name|container_name' terraform.tfstate



#--------------------------------------+---------------------------------------8
#                                                                              |
#                         REINITIALIZE - SAP_LIBRARY                           |
#                                                                              |
#--------------------------------------+---------------------------------------8

# Duration of Task      : 3 minutes


# cat <<EOF > backend.tf
# terraform {
#   backend azurerm {
#     resource_group_name   = "NP-EUS2-SAP_LIBRARY"
#     storage_account_name  = "globaeus2tfstate1c46"
#     container_name        = "saplibrary"
#     key                   = "NP-EUS2-SAP_LIBRARY.terraform.tfstate"
#   }
# }
# EOF


terraform init                                                                       \
               --backend-config "resource_group_name=NP-EUS2-SAP_LIBRARY"            \
               --backend-config "storage_account_name=globaeus2tfstate1c46"             \
               --backend-config "container_name=tfstate"                             \
               --backend-config "key=NP-EUS2-SAP_LIBRARY.terraform.tfstate"          \
               ../../../sap-hana/deploy/terraform/run/sap_deployer/

rm terraform.tfstate*

terraform plan                                                                       \
                --var-file=NP-EUS2-SAP_LIBRARY.json                                  \
                ../../../sap-hana/deploy/terraform/run/sap_library 

time terraform apply                                                                 \
                     --auto-approve                                                  \
                     --var-file=NP-EUS2-SAP_LIBRARY.json                             \
                     ../../../sap-hana/deploy/terraform/run/sap_library/

# Run Time < 1m



#--------------------------------------+---------------------------------------8
#                                                                              |
#                              REINITIALIZE - DEP00                            |
#                                                                              |
#--------------------------------------+---------------------------------------8

# Duration of Task      : 3 minutes

cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/LOCAL/NP-EUS2-DEP00-INFRASTRUCTURE
egrep -wi 'resource_group_name|storage_account_name|container_name' ../../SAP_LIBRARY/NP-EUS2-SAP_LIBRARY/.terraform/terraform.tfstate

# cat <<EOF > backend.tf
# terraform {
#   backend azurerm {
#     resource_group_name   = "NP-EUS2-SAP_LIBRARY"
#     storage_account_name  = "globaeus2tfstate1c46"
#     container_name        = "tfstate"
#     key                   = "NP-EUS2-DEP00-INFRASTRUCTURE.terraform.tfstate"
#   }
# }
# EOF


terraform init                                                                       \
               --backend-config "resource_group_name=NP-EUS2-SAP_LIBRARY"            \
               --backend-config "storage_account_name=globaeus2tfstate1c46"             \
               --backend-config "container_name=tfstate"                             \
               --backend-config "key=NP-EUS2-DEP00-INFRASTRUCTURE.terraform.tfstate" \
               ../../../sap-hana/deploy/terraform/run/sap_deployer/


rm terraform.tfstate*


terraform plan                                                                       \
                --var-file=NP-EUS2-DEP00-INFRASTRUCTURE.json                         \
                ../../../sap-hana/deploy/terraform/run/sap_deployer/


time terraform apply --auto-approve                                                  \
                     --var-file=NP-EUS2-DEP00-INFRASTRUCTURE.json                    \
                     ../../../sap-hana/deploy/terraform/run/sap_deployer/


# Run Time < 1m



#--------------------------------------+---------------------------------------8
#                                                                              |
#                            DEPLOY - WORKLOAD VNET                            |
#                                                                              |
#--------------------------------------+---------------------------------------8

# Duration of Task      : 5 minutes

mkdir -p ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_LANDSCAPE/NP-EUS2-SAP0-INFRASTRUCTURE; cd $_
cp ../../LOCAL/NP-EUS2-DEP00-INFRASTRUCTURE/sshkey* .

# cat <<EOF > backend.tf
# terraform {
#   backend azurerm {
#     resource_group_name   = "NP-EUS2-SAP_LIBRARY"
#     storage_account_name  = "globaeus2tfstate1c46"
#     container_name        = "tfstate"
#     key                   = "NP-EUS2-SAP0-INFRASTRUCTURE.terraform.tfstate"
#   }
# }
# EOF

vi NP-EUS2-SAP0-INFRASTRUCTURE.json


terraform init                                                                       \
                --backend-config "resource_group_name=NP-EUS2-SAP_LIBRARY"           \
                --backend-config "storage_account_name=globaeus2tfstate1c46"            \
                --backend-config "container_name=tfstate"                            \
                --backend-config "key=NP-EUS2-SAP0-INFRASTRUCTURE.terraform.tfstate" \
                ../../../sap-hana/deploy/terraform/run/sap_system/


terraform plan                                                                       \
                --var-file=NP-EUS2-SAP0-INFRASTRUCTURE.json                          \
                ../../../sap-hana/deploy/terraform/run/sap_system/


time terraform apply --auto-approve                                                  \
                     --var-file=NP-EUS2-SAP0-INFRASTRUCTURE.json                     \
                     ../../../sap-hana/deploy/terraform/run/sap_system/


# Run Time < 1m



#--------------------------------------+---------------------------------------8
#                                                                              |
#                                 DEPLOY - SID                                 |
#                                      X00                                     |
#                                                                              |
#--------------------------------------+---------------------------------------8

# Duration of Task      : 12 minutes

mkdir -p ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_SYSTEM/NP-EUS2-SAP0-X00; cd $_
cp ../../LOCAL/NP-EUS2-DEP00-INFRASTRUCTURE/sshkey* .

# cat <<EOF > backend.tf
# terraform {
#   backend azurerm {
#     resource_group_name   = "NP-EUS2-SAP_LIBRARY"
#     storage_account_name  = "globaeus2tfstate1c46"
#     container_name        = "tfstate"
#     key                   = "NP-EUS2-SAP0-X00.terraform.tfstate"
#   }
# }
# EOF

vi NP-EUS2-SAP0-X00.json


cat <<EOF > backend
resource_group_name   = "NP-EUS2-SAP_LIBRARY"
storage_account_name  = "globaeus2tfstate1c46"
container_name        = "tfstate"
key                   = "NP-EUS2-SAP0-X00.terraform.tfstate"
EOF


terraform init                                                                       \
                --backend-config backend                                             \
                ../../../sap-hana/deploy/terraform/run/sap_system/


# terraform init                                                                       \
#                 --backend-config "resource_group_name=NP-EUS2-SAP_LIBRARY"           \
#                 --backend-config "storage_account_name=globaeus2tfstate1c46"            \
#                 --backend-config "container_name=tfstate"                            \
#                 --backend-config "key=NP-EUS2-SAP0-X00.terraform.tfstate"            \
#                 ../../../sap-hana/deploy/terraform/run/sap_system/


terraform plan                                                                       \
                --var-file=NP-EUS2-SAP0-X00.json                                     \
                ../../../sap-hana/deploy/terraform/run/sap_system/


time terraform apply --auto-approve                                                  \
                     --var-file=NP-EUS2-SAP0-X00.json                                \
                     ../../../sap-hana/deploy/terraform/run/sap_system/


# Run Time ~ 10m



#--------------------------------------+---------------------------------------8
#                                                                              |
#                                 DEPLOY - SID                                 |
#                                      X01                                     |
#                                                                              |
#--------------------------------------+---------------------------------------8

mkdir -p ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_SYSTEM/NP-EUS2-SAP0-X01; cd $_
cp ../../LOCAL/NP-EUS2-DEP00-INFRASTRUCTURE/sshkey* .


vi NP-EUS2-SAP0-X01.json


cat <<EOF > backend
resource_group_name   = "NP-EUS2-SAP_LIBRARY"
storage_account_name  = "globaeus2tfstate1c46"
container_name        = "tfstate"
key                   = "NP-EUS2-SAP0-X01.terraform.tfstate"
EOF


terraform init                                                                       \
                --backend-config backend                                             \
                ../../../sap-hana/deploy/terraform/run/sap_system/


terraform plan                                                                       \
                --var-file=NP-EUS2-SAP0-X01.json                                     \
                ../../../sap-hana/deploy/terraform/run/sap_system/


time terraform apply --auto-approve                                                  \
                     --var-file=NP-EUS2-SAP0-X01.json                                \
                     ../../../sap-hana/deploy/terraform/run/sap_system/


# Run Time ~ 10m



#--------------------------------------+---------------------------------------8
#                                                                              |
#                                 DEPLOY - SID                                 |
#                                      X02                                     |
#                                                                              |
#--------------------------------------+---------------------------------------8

mkdir -p ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_SYSTEM/NP-EUS2-SAP0-X02; cd $_
cp ../../LOCAL/NP-EUS2-DEP00-INFRASTRUCTURE/sshkey* .


vi NP-EUS2-SAP0-X02.json


cat <<EOF > backend
resource_group_name   = "NP-EUS2-SAP_LIBRARY"
storage_account_name  = "globaeus2tfstate1c46"
container_name        = "tfstate"
key                   = "NP-EUS2-SAP0-X02.terraform.tfstate"
EOF


terraform init                                                                       \
                --backend-config backend                                             \
                ../../../sap-hana/deploy/terraform/run/sap_system/


terraform plan                                                                       \
                  --var-file=NP-EUS2-SAP0-X02.json                                   \
                  ../../../sap-hana/deploy/terraform/run/sap_system/


time terraform apply --auto-approve                                                  \
                     --var-file=NP-EUS2-SAP0-X02.json                                \
                     ../../../sap-hana/deploy/terraform/run/sap_system/


# Run Time < 1m



#--------------------------------------+---------------------------------------8
#                                                                              |
#                                   DESTROY                                    |
#                                     ALL                                      |
#                                                                              |
#--------------------------------------+---------------------------------------8


cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_SYSTEM/NP-EUS2-SAP0-X00
terraform destroy --auto-approve                                                     \
                  --var-file=NP-EUS2-SAP0-X00.json                                   \
                  ../../../sap-hana/deploy/terraform/run/sap_system/


cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_SYSTEM/NP-EUS2-SAP0-X01
terraform destroy --auto-approve                                                     \
                  --var-file=NP-EUS2-SAP0-X01.json                                   \
                  ../../../sap-hana/deploy/terraform/run/sap_system/


cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_SYSTEM/NP-EUS2-SAP0-X02
terraform destroy --auto-approve                                                     \
                  --var-file=NP-EUS2-SAP0-X02.json                                   \
                  ../../../sap-hana/deploy/terraform/run/sap_system/


cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SAP_LANDSCAPE/NP-EUS2-SAP0-INFRASTRUCTURE
terraform destroy --auto-approve                                                     \
                  --var-file=NP-EUS2-SAP0-INFRASTRUCTURE.json                        \
                  ../../../sap-hana/deploy/terraform/run/sap_system/

