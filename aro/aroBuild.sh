#!/bin/bash

set -u


echo "Please ensure that Azure CLI is installed...."

read -p "Do you want to proceed? (yes/no) " yn

case $yn in 
	yes ) echo ok, we will proceed;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;

esac

echo "Let's check you weren't lying...."

# Check if the user is logged in to Azure
if az account show &>/dev/null; then
    echo "User is logged in to Azure."
else
    echo "You were lying!!! User is not logged in to Azure. Please log in using 'az login' before running this script."
    exit 1
fi

# Continue with the rest of your script here


echo "Please provide the following details before continuing:"

echo ""

read -p "Provide Azure Resource Location [Default value - eastus]: " AZR_RESOURCE_LOCATION
AZR_RESOURCE_LOCATION=${AZR_RESOURCE_LOCATION:-eastus}
echo $AZR_RESOURCE_LOCATION

read -p "Provide Azure Resource Group - (already created by RHDPS): " AZR_RESOURCE_GROUP

read -p "Provide Azure Subscription - (already created by RHDPS): " AZR_SUBSCRIPTION
red_prefix="\033[31m"
red_suffix="\033[00m"
echo -e "$red_prefix" If you get an error that the resource group wasnt found for RHDPS. Use command az login --tenant xyz to login to the RHDPS directory. Command to list current tenants or directories is az account tenant list. "$red_suffix"

read -p "Provide Cluster Name: " AZR_CLUSTER

read -p "Provide Redhat Pull Secret (Location-only) [Default - ./pull-secret.txt]: " AZR_PULL_SECRET

AZR_PULL_SECRET=${AZR_PULL_SECRET:-./pull-secret.txt}

echo $AZR_PULL_SECRET
# Check if the variable is set
if [ -z "$AZR_PULL_SECRET" ]; then
    echo "Pull Secret is empty please specify absolute path and try again. Tip: Download to current directory and select default option"
    exit 1
fi

# If variable is not empty, continue script execution
echo "Pull secret looks good moving on!"


echo "Setting the subscription for the local env"

az account set --subscription $AZR_SUBSCRIPTION

echo "Creating a Virtual Network for the cluster....."

az network vnet create   --address-prefixes 10.0.0.0/22   --name "$AZR_CLUSTER-aro-vnet-$AZR_RESOURCE_LOCATION"   --resource-group $AZR_RESOURCE_GROUP --location $AZR_RESOURCE_LOCATION

echo "Creating Control Plane Subnet...."

az network vnet subnet create   --resource-group $AZR_RESOURCE_GROUP   --vnet-name "$AZR_CLUSTER-aro-vnet-$AZR_RESOURCE_LOCATION"   --name "$AZR_CLUSTER-aro-control-subnet-$AZR_RESOURCE_LOCATION"   --address-prefixes 10.0.0.0/23   --service-endpoints Microsoft.ContainerRegistry

echo "Creating Machine Subnet...."

az network vnet subnet create   --resource-group $AZR_RESOURCE_GROUP   --vnet-name "$AZR_CLUSTER-aro-vnet-$AZR_RESOURCE_LOCATION"   --name "$AZR_CLUSTER-aro-machine-subnet-$AZR_RESOURCE_LOCATION"   --address-prefixes 10.0.2.0/23   --service-endpoints Microsoft.ContainerRegistry

echo "Disable Network Policies on the Control Plane Subnet...."

az network vnet subnet update \
  --name "$AZR_CLUSTER-aro-control-subnet-$AZR_RESOURCE_LOCATION" \
  --resource-group $AZR_RESOURCE_GROUP \
  --vnet-name "$AZR_CLUSTER-aro-vnet-$AZR_RESOURCE_LOCATION" \
  --disable-private-link-service-network-policies true

echo "Creating the cluster....(30-45 mins)....."

az aro create \
  --resource-group $AZR_RESOURCE_GROUP \
  --name $AZR_CLUSTER \
  --vnet "$AZR_CLUSTER-aro-vnet-$AZR_RESOURCE_LOCATION" \
  --master-subnet "$AZR_CLUSTER-aro-control-subnet-$AZR_RESOURCE_LOCATION" \
  --worker-subnet "$AZR_CLUSTER-aro-machine-subnet-$AZR_RESOURCE_LOCATION" \
  --pull-secret @$AZR_PULL_SECRET

echo "Logging into the ARO cluster..."
apiServer=$(az aro show -g $AZR_RESOURCE_GROUP -n $AZR_CLUSTER --query apiserverProfile.url -o tsv)
kubcepass=$(az aro list-credentials --name $AZR_CLUSTER -g $AZR_RESOURCE_GROUP --query kubeadminPassword -o tsv)
oc login $apiServer -u kubeadmin -p $kubcepass
# Openshift prep before connecting
oc adm policy add-scc-to-user privileged system:serviceaccount:azure-arc:azure-arc-kube-aad-proxy-sa
echo ""

apiServerURI="${apiServer#https://}"
clusterName="${apiServerURI//[.]/-}"
user="kube:admin"
context="default/$clusterName$user"

oc get nodes

oc whoami --show-console