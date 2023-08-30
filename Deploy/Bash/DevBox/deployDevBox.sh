#!/bin/bash

# Description:
# This script automates the creation of an Azure Resource Group, a Virtual Network (VNet) inside that Resource Group,
# and sets up a network connection for Azure Development Center with domain-join capabilities.

# Function to display the planned actions
display_info() {
    cat <<- EOF
-----------------------------------------
Azure Resource Automation Script
-----------------------------------------
Subscription ID: $subscriptionId
Resource Group: $devBoxResourceGroupName
Location: $location
VNet Name: $vnetName
Subnet Name: $subnetName
-----------------------------------------
EOF
}

# Main execution
main() {
    # Ensure necessary arguments are provided
    if [ "$#" -lt 5 ]; then
        echo "Error: Expected 5 arguments, received $#."
        echo "Usage: $0 [SUBSCRIPTION_ID] [LOCATION] [FRONT_END_IMAGE_NAME] [BACK_END_IMAGE_NAME] [IMAGE_RESOURCE_GROUP_NAME]"
        exit 1
    fi

    # Assign arguments to variables
    subscriptionId="$1"
    location="$2"
    # The following variables are received but not used in this script. Are they needed elsewhere?
    frontEndImageName="$3"
    backEndImageName="$4"
    imageResourceGroupName="$5"

    # Define fixed variables for the resource group, virtual network, and subnet names.
    devBoxResourceGroupName="Contoso-DevBox-rg"
    vnetName="Contoso-AzureDevBox-vnet"
    subnetName="Contoso-AzureDevBox-subnet"

    # Display planned actions for user clarity
    display_info

    # Create a new resource group using the Azure CLI
    echo "Creating Resource Group: $devBoxResourceGroupName in location: $location..."
    az group create -n "$devBoxResourceGroupName" -l "$location"

    # Check for any errors after running Azure CLI command
    if [ $? -ne 0 ]; then
        echo "Error creating Resource Group."
        exit 1
    fi

    # Create the Virtual Network and subnet
    echo "Creating Virtual Network: $vnetName and Subnet: $subnetName..."
    ./Vnet/deployVnet.sh "$devBoxResourceGroupName" "$location" "$vnetName" "$subnetName"

    if [ $? -ne 0 ]; then
        echo "Error creating Virtual Network and Subnet."
        exit 1
    fi

    # Set up a network connection for Azure Development Center
    echo "Setting up Network Connection for Azure Development Center..."
    ./Vnet/createNetWorkConnection.sh "$location" "$subscriptionId" "$devBoxResourceGroupName" "$vnetName" "$subnetName"

    if [ $? -ne 0 ]; then
        echo "Error setting up Network Connection for Azure Development Center."
        exit 1
    fi

    cat <<- EOF
-----------------------------------------
Azure Resource Creation Completed!
-----------------------------------------
All operations completed successfully!
EOF
}

# Invoke the main function
main "$@"
