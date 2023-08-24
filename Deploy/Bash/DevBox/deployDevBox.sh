#!/usr/bin/env bash

# Description:
# This script automates the creation of an Azure Resource Group, a Virtual Network (VNet) inside that Resource Group,
# and sets up a network connection for Azure Development Center with domain-join capabilities.

display_info() {
    echo "-----------------------------------------"
    echo "Azure Resource Automation Script"
    echo "-----------------------------------------"
    echo "Subscription ID: $subscriptionId"
    echo "Resource Group: $devBoxResourceGroupName"
    echo "Location: $location"
    echo "VNet Name: $vnetName"
    echo "Subnet Name: $subnetName"
    echo "-----------------------------------------"
}

# Ensure necessary arguments are provided
if [ "$#" -lt 5 ]; then
    echo "Error: Expected 5 arguments, received $#."
    echo "Usage: $0 [SUBSCRIPTION_ID] [LOCATION] [FRONT_END_IMAGE_NAME] [BACK_END_IMAGE_NAME] [IMAGE_RESOURCE_GROUP_NAME]"
    exit 1
fi

# Assign arguments to variables
subscriptionId="$1"
location="$2"
frontEndImageName="$3"
backEndImageName="$4"
imageResourceGroupName="$5"

# Define fixed variables for the resource group, location, virtual network, and subnet names.
devBoxResourceGroupName="Contoso-DevBox-rg"
vnetName="Contoso-AzureDevBox-vnet"
subnetName="Contoso-AzureDevBox-subnet"

# Display planned actions for user clarity
display_info

# Create a new resource group using the Azure CLI
echo "Creating Resource Group: $devBoxResourceGroupName in location: $location..."
az group create -n "$devBoxResourceGroupName" -l "$location"

# Create the Virtual Network and subnet
echo "Creating Virtual Network: $vnetName and Subnet: $subnetName..."
./Vnet/deployVnet.sh "$devBoxResourceGroupName" "$location" "$vnetName" "$subnetName"

# Set up a network connection for Azure Development Center
echo "Setting up Network Connection for Azure Development Center..."
./Vnet/createNetWorkConnection.sh "$location" "$subscriptionId" "$devBoxResourceGroupName" "$vnetName" "$subnetName"

echo "-----------------------------------------"
echo "Azure Resource Creation Completed!"
echo "-----------------------------------------"

echo "All operations completed successfully!"
