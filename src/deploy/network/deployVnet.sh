#!/bin/bash

# This script creates an Azure Virtual Network and Subnet within a specified Resource Group.

set -e  # Exit if any command fails

# Functions

checkAzCliInstalled() {
    if ! command -v az &> /dev/null; then
        echo "az CLI could not be found. Please install it before running this script."
        exit 1
    fi
}

ensureArgumentsPassed() {
    if [ "$#" -ne 4 ]; then
        echo "Usage: $0 <resourceGroupName> <location> <vnetName> <subnetName>"
        exit 1
    fi
}

createVirtualNetworkAndSubnet() {
    local resourceGroupName="$1"
    local location="$2"
    local vnetName="$3"
    local subnetName="$4"
    local vnetAddressPrefix="10.0.0.0/16"
    local subnetAddressPrefix="10.0.0.0/24"

    # Constants
    branch="main"
    templateFileUri="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy//ARMTemplates/network/vNet/vNetTemplate.json"

    echo "Starting the creation of Virtual Network and Subnet..."
    echo "Creating Virtual Network: $vnetName in Resource Group: $resourceGroupName with address prefix: $vnetAddressPrefix..."

    az deployment group create \
        --name "$vnetName" \
        --resource-group "$resourceGroupName" \
        --template-uri $templateFileUri \
        --parameters vnetName="$vnetName" 
    
    # az network vnet create \
    #     --resource-group "$resourceGroupName" \
    #     --location "$location" \
    #     --name "$vnetName" \
    #     --address-prefix "$vnetAddressPrefix" \
    #     --subnet-name "$subnetName" \
    #     --subnet-prefix "$subnetAddressPrefix" \
    #     --tags "division=petv2-Platform" \
    #             "Environment=Prod" \
    #             "offer=petv2-DevWorkstation-Service" \
    #             "Team=Engineering" \
    #             "solution=ContosoFabricDevWorkstation"
    
    echo "Virtual Network $vnetName and Subnet $subnetName have been created successfully in Resource Group $resourceGroupName."
}

# Main execution

checkAzCliInstalled
ensureArgumentsPassed "$@"
createVirtualNetworkAndSubnet "$@"
