# Workload Profile for Azure Container Apps

## Create Workload Profile

Deploy a new Container Apps Environment with a workload profile using Terraform.

```sh
terraform init
terraform apply -auto-approve
```

Deploy new Container App attached to the workload profile created in Terraform.

```sh
az containerapp create -n webapp -g rg-aca-workload-profile 
   --target-port 80 --ingress external --image nginx:latest --environment aca-environment 
   --workload-profile-name profile-D8
```