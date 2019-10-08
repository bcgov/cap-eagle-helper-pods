# Azure deployment
This deployment includes deploying a storage account blob only under it's own resource group in canadacentral.  This is to be used for storage migration as part of the CWU Cloud Discovery project.

These are instructions for linux-based machines, however provider documentation is linked below if you want to run from another platform


## Terraform
Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
```
wget https://releases.hashicorp.com/terraform/0.12.7/terraform_0.12.7_linux_amd64.zip
unzip terraform_0.12.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/terraform
```


## Setting up prereqs for Azure provider
1. Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
2. Login via Azure CLI
```
az login
```
3. Grab your subscription id from the output of the following command
```
az account list
```
4. Create new service principal, this is the account we'll use to create and delete resources via Terraform
```
az ad sp create-for-rbac --name cwu_terraform --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID from above>"
```
5. This will print a JSON payload similar to the following
```
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "cwu_terraform",
  "name": "http://cwu_terraform",
  "password": "xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```
6. Capture the appId, password and tenant.  Export them as follows
```
export ARM_CLIENT_ID=<insert the appId from above>
export ARM_SUBSCRIPTION_ID=<insert your subscription id>
export ARM_TENANT_ID=<insert the tenant from above>
export ARM_CLIENT_SECRET=<insert the password from above>
export TF_VAR_service_principal_client_id=$ARM_CLIENT_ID
export TF_VAR_service_principal_client_secret=$ARM_CLIENT_SECRET
export TF_VAR_email_letsencrypt=<your email address>
```

## Run terraform to deploy the template
```
terraform init
terraform apply
```
Have to type 'yes' for this to kick off after reviewing the plan.  This part will take a few mins

Run the following to verify the storage account is available and to obtain access keys
```
az storage account keys list --account-name bcgovcapstorage
```

Note that for integration into an application for use as an object store, for those that are more familiar with other object storage services such as S3 that use access and secret keys the mapping is
```
azure storage account name == s3 access key
azure storage access key == s3 secret key