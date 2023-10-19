#!/bin/bash

# This script creates an Azure Virtual Network and Subnet within a specified Resource Group.

# Exit if any command fails
set -e

# Check if az CLI is installed
if ! command -v az &> /dev/null
then
    echo "az CLI could not be found. Please install it before running this script."
    exit
fi

# Ensure required arguments are passed
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <Resource Group Name> <Location> <VNet Name> <Subnet Name>"
    exit 1
fi

# Assign arguments to meaningful variable names with comments.
resourceGroupName="$1" # Name of the resource group.
location="$2"          # Azure Region location where the resources will be created.
vnetName="$3"          # Name of the virtual network.
subnetName="$4"        # Name of the subnet to be created within the virtual network.

# Declare additional variables with comments.
vnetAddressPrefix="10.0.0.0/16" # Address prefix for the virtual network.
subnetAddressPrefix="10.0.0.0/24" # Address prefix for the subnet within the virtual network.

# Inform the user about the start of the process.
echo "Starting the creation of Virtual Network and Subnet..."

# Create the Virtual Network and Subnet using the Azure CLI.
echo "Creating Virtual Network: $vnetName in Resource Group: $resourceGroupName with address prefix: $vnetAddressPrefix..."
az network vnet create \
    --resource-group "$resourceGroupName" \
    --location "$location" \
    --name "$vnetName" \
    --address-prefix "$vnetAddressPrefix" \
    --subnet-name "$subnetName" \
    --subnet-prefix "$subnetAddressPrefix" \
    --tags "division=Contoso-Platform" \
            "Environment=Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "division=Contoso-Platform" \
            "solution=ContosoFabricDevWorkstation"

# Inform the user that the resources have been created successfully.
echo "Virtual Network $vnetName and Subnet $subnetName have been created successfully in Resource Group $resourceGroupName with tags $tags."

