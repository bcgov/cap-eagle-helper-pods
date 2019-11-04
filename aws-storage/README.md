# AWS deployment
This deployment includes deploying an S3 bucket in canada central.  This is to be used for storage migration as part of the CWU Cloud Discovery project.

## Terraform and AWS CLI automated installations
Run `install-prereqs.sh` to have these auto-installed for you

## Terraform and AWS CLI manual installation
These are instructions for linux-based machines, however provider documentation is linked below if you want to run from another platform

Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
```
wget https://releases.hashicorp.com/terraform/0.12.7/terraform_0.12.7_linux_amd64.zip
unzip terraform_0.12.7_linux_amd64.zip
mv terraform ~
```

Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html)
```
sudo apt-get install python
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
echo "export PATH=~/.local/bin:$PATH" > ~/.bash_profile
source ~/.bash_profile
pip install awscli --upgrade --user
```


## Setting up prereqs for AWS provider
1. Login to your AWS console, and create a new IAM user called terraform with programmatic access.  Assign it the Administrator policy so it has full access to create/delete any resources required.  Copy the access and secret keys
2. Configure credentials file using AWS CLI
```
aws configure
```
3. Enter the access and secret keys from above, and leave default region and default output as none


## Run terraform to deploy the template
```
terraform init
terraform apply
```
Have to type 'yes' for this to kick off after reviewing the plan.  This part will take a few mins

The template will create the required resources and output the access and secret keys needed for accessing the S3 bucket.  Copy these for deployment into MinIO and deployment of OpenShift templates.

**WARNING** These keys cannot be retrieved once you close the terminal window, you will have to either manually provision new access keys for the bcgovcapstorage user and update the IAM policy with the new key ID, or destroy/apply to recreate all resources


## Run terraform to deprovision resources
```
terraform destroy

```
Have to type 'yes' for this to kick off after reviewing the plan.  This part will take a few mins