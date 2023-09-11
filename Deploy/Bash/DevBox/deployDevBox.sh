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
Resource Group: $imageResourceGroupName
Location: $location
VNet Name: $vnetName
Subnet Name: $subnetName
Identity Name: $identityName
-----------------------------------------
EOF
}

# Main execution
main() {
    # Ensure necessary arguments are provided
    if [ "$#" -lt 4 ]; then
        echo "Error: Expected 5 arguments, received $#."
        echo "Usage: $0 [SUBSCRIPTION_ID] [LOCATION] [IMAGE_RESOURCE_GROUP_NAME] [IDENTITY_NAME]"
        exit 1
    fi

    # Assign arguments to variables
    subscriptionId="$1"
    location="$2"
    # The following variables are received but not used in this script. Are they needed elsewhere?
    imageResourceGroupName="$3"
    identityName="$4"

    # Define fixed variables for the resource group, virtual network, and subnet names.
    vnetName="Contoso-DevBox-vnet"
    subnetName="Contoso-DevBox-subnet"
    devCenterName="Contoso-DevBox-DevCenter"

    # Display planned actions for user clarity
    display_info

    # Check for any errors after running Azure CLI command
    if [ $? -ne 0 ]; then
        echo "Error creating Resource Group."
        exit 1
    fi

    # Create the Virtual Network and subnet
    echo "Creating Virtual Network: $vnetName and Subnet: $subnetName..."
    ./Vnet/deployVnet.sh "$imageResourceGroupName" "$location" "$vnetName" "$subnetName"

    if [ $? -ne 0 ]; then
        echo "Error creating Virtual Network and Subnet."
        exit 1
    fi

    # Set up a network connection for Azure Development Center
    echo "Setting up Network Connection for Azure Development Center..."
    ./Vnet/createNetWorkConnection.sh "$location" "$subscriptionId" "$imageResourceGroupName" "$vnetName" "$subnetName"
    
    ./DevBox/deployDevCenter.sh "$devCenterName" "$imageResourceGroupName" "$location" "$identityName" "$subscriptionId"

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
