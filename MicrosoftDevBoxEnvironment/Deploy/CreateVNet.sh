#!/bin/bash

# This script creates a Virtual Network (VNet) and a subnet within that VNet in Azure.

# Displaying a header to provide clarity on the operation being performed.
echo "-----------------"
echo "Creating VNet in Azure"
echo "-----------------"

# Fetching the Azure resource group name from the first argument and displaying it.
resourceGroupName=$1
echo "Resource Group Name: $resourceGroupName"

# Fetching the Azure region/location from the second argument and displaying it.
location=$2
echo "Azure Region/Location: $location"

# Fetching the name of the Virtual Network from the third argument and displaying it.
vnetName=$3
echo "Virtual Network Name: $vnetName"

# Fetching the name of the subnet from the fourth argument and displaying it.
subnetName=$4
echo "Subnet Name: $subnetName"
echo "-----------------"

# Informing the user about the upcoming operation.
echo "Initiating the creation of the VNet and subnet..."

# Using the Azure CLI to create the Virtual Network with a pre-defined address prefix.
# Also, a subnet is instantiated within this VNet with a specified name and address prefix.
az network vnet create \
    --resource-group $resourceGroupName \
    --name $vnetName \
    --address-prefix 10.0.0.0/16 \
    --subnet-name $subnetName \
    --subnet-prefix 10.0.1.0/24

# Confirming the successful creation of the VNet and subnet.
echo "Virtual Network '$vnetName' and Subnet '$subnetName' have been successfully created!"
