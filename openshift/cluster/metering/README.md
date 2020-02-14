# Install Metering on OpenShift 3.11
The Metering Operator is officially released with OpenShift 4, however for the purposes of exploring billing models and data we went through the following manual install vs OLM to get it working on OpenShift 3.11 on the IBM Cloud OpenShift cluster where we have cluster admin rights

https://github.com/operator-framework/operator-metering/blob/master/Documentation/install-metering.md

https://github.com/operator-framework/operator-metering/blob/master/Documentation/manual-install.md


## Prereqs
The installation must be done from a linux or mac machine, Ubuntu under WSL was used for this install

Install faq, run this
```shell
LATEST_RELEASE=$(curl -s https://api.github.com/repos/jzelinskie/faq/releases | cat | head -n 10 | grep "tag_name" | cut -d\" -f4)
sudo curl -Lo /usr/local/bin/faq https://github.com/jzelinskie/faq/releases/download/$LATEST_RELEASE/faq-linux-amd64
sudo chmod +x /usr/local/bin/faq
```

Clone this repo
https://github.com/operator-framework/operator-metering.git


## Storage Customization
We couldn't use a PVC to store billing data as is the default as the File storage classes that support RWX weren't working in IBM Cloud.  Thus, we switched to storing the data in an Azure blob object storage account, as the IBM Cloud account doesn't have credits for object storage just the OpenShift cluster and any File and Block storage needed
1. Create a new namespace called metering-test
2. Create a new secret called metering-azure-secret
2. Copy manifests/metering-config/azure-blob-storage.yaml to metering-custom.yaml
3. Edit metering-custom.yaml to point to the secret and config for Azure object storage backend, see [metering-custom.yaml](metering-custom.yaml) for an example

If you have a storage class that supports read/write-many, and you want to use a local PVC instead, customize your metering-custom.yaml from manifests/metering-config/default.yaml instead, otherwise it will create a PVC with those default settings if you don't specify METERING_CR_FILE below


## Installation
Ensure you are in the cloned root directory of operator-metering, and run the following
```shell
export METERING_NAMESPACE=metering-test
export METERING_CR_FILE=metering-custom.yaml
./hack/openshift-install.sh
```

Follow verification steps in install doc to check everything worked.  For details on creating and viewing reports, check this section here
https://github.com/operator-framework/operator-metering/blob/master/Documentation/reports.md