#!/bin/bash

# This script creates a Virtual Network (VNet) and a subnet within that VNet in Azure.

# Exit immediately if a command exits with a non-zero status.
set -e

# Constants
readonly SCRIPT_NAME=$(basename "$0")
readonly ADDRESS_PREFIX="10.0.0.0/16"
readonly SUBNET_PREFIX="10.0.1.0/24"

# Function to display a usage message when the script is not executed correctly.
usage() {
    echo "Usage: $SCRIPT_NAME <RESOURCE_GROUP_NAME> <AZURE_REGION> <VNET_NAME> <SUBNET_NAME>"
    exit 1
}

# Check for the correct number of arguments.
if [ "$#" -ne 4 ]; then
    echo "Error: Incorrect number of arguments provided."
    usage
fi

# Assign arguments to meaningful variable names.
resourceGroupName="$1"
location="$2"
vnetName="$3"
subnetName="$4"

# Display the operation details.
cat << INFO
----------------------------------
       Creating VNet in Azure      
----------------------------------
Resource Group Name: $resourceGroupName
Azure Region/Location: $location
Virtual Network Name: $vnetName
Subnet Name: $subnetName
----------------------------------
INFO

# Informing the user about the upcoming operation.
echo "Initiating the creation of the VNet and subnet..."

# Create the Virtual Network and Subnet using the Azure CLI.
az network vnet create \
    --resource-group "$resourceGroupName" \
    --name "$vnetName" \
    --address-prefix "$ADDRESS_PREFIX" \
    --subnet-name "$subnetName" \
    --subnet-prefix "$SUBNET_PREFIX" \
     --tags  "division=Contoso-Platform" \
            "Environment=Dev-Workstation" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=eShopOnContainers" 

# Confirming the successful creation of the VNet and subnet.
echo "Success: Virtual Network '$vnetName' and Subnet '$subnetName' have been created."
