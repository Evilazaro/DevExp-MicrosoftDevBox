#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Description: This script creates a Virtual Network (VNet) and a subnet within that VNet in Azure.

# Constants
readonly SCRIPT_NAME=$(basename "$0")
readonly ADDRESS_PREFIX="10.0.0.0/16"
readonly SUBNET_PREFIX="10.0.1.0/24"

# Function to display a usage message when the script is not executed correctly.
usage() {
    echo "Usage: $SCRIPT_NAME <RESOURCE_GROUP_NAME> <AZURE_REGION> <VNET_NAME> <SUBNET_NAME>"
    exit 1
}

# Check for the right number of arguments.
if [ "$#" -ne 4 ]; then
    echo "Error: Incorrect number of arguments provided."
    usage
fi

# Assigning arguments to meaningful variable names
resourceGroupName="$1"
location="$2"
vnetName="$3"
subnetName="$4"

# Display information
cat << INFO
--------------------------
Creating VNet in Azure
--------------------------
Resource Group Name: $resourceGroupName
Azure Region/Location: $location
Virtual Network Name: $vnetName
Subnet Name: $subnetName
--------------------------
INFO

# Informing the user about the upcoming operation.
echo "Initiating the creation of the VNet and subnet..."

# Using the Azure CLI to create the Virtual Network with a pre-defined address prefix.
# Also, a subnet is instantiated within this VNet with a specified name and address prefix.
az network vnet create \
    --resource-group "$resourceGroupName" \
    --name "$vnetName" \
    --address-prefix "$ADDRESS_PREFIX" \
    --subnet-name "$subnetName" \
    --subnet-prefix "$SUBNET_PREFIX"

# Confirming the successful creation of the VNet and subnet.
echo "Virtual Network '$vnetName' and Subnet '$subnetName' have been successfully created!"
