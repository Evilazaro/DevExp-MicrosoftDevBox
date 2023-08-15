#!/bin/bash

# This script automates the creation of an Azure Resource Group, a Virtual Network (VNet) inside that Resource Group, 
# and sets up a network connection for Azure Development Center with domain-join capabilities.

# Check if a subscription ID has been provided. If not, exit the script with an error message.
if [ -z "$1" ]; then
    echo "Error: Subscription ID not provided!"
    echo "Usage: $0 [SUBSCRIPTION_ID]"
    exit 1
fi

# Set the Azure subscription ID from the first argument.
subscriptionId=$1

# Define fixed variables for the resource group, location, virtual network, and subnet names.
resourceGroupName="Contoso-AzureDevBox-rg"
location="WestUS3"
vnetName="Contoso-AzureDevBox-vnet"
subnetName="Contoso-AzureDevBox-subnet"

# Display the planned actions for user clarity.
echo "-----------------------------------------"
echo "Azure Resource Automation Script"
echo "-----------------------------------------"
echo "Subscription ID: $subscriptionId"
echo "Resource Group: $resourceGroupName"
echo "Location: $location"
echo "VNet Name: $vnetName"
echo "Subnet Name: $subnetName"
echo "-----------------------------------------"

# Create a new resource group using the Azure CLI.
echo "Creating Resource Group..."
az group create -n $resourceGroupName -l $location

# Call an external script (CreateVNet.sh) to create the Virtual Network and subnet.
echo "Creating Virtual Network and Subnet..."
./CreateVNet.sh $resourceGroupName $location $vnetName $subnetName

# Setting up a network connection for Azure Development Center.
echo "Setting up Network Connection for Azure Development Center..."
./CreateNetworkConnection.sh $location $resourceGroupName $vnetName $subnetName $subscriptionId

echo "-----------------------------------------"
echo "Azure Resource Creation Completed!"
echo "-----------------------------------------"
