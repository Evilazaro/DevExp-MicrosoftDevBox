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
Resource Group: $resourceGroupName
Location: $location
VNet Name: $vnetName
Subnet Name: $subnetName
Identity Name: $identityName
-----------------------------------------
EOF
}

# Function to check the exit status of the last executed command and display an error message if it failed
check_exit_status() {
    if [ $? -ne 0 ]; then
        echo "$1"
        exit 1
    fi
}

# Main execution function
main() {
    # Ensure necessary arguments are provided
    if [ "$#" -lt 5 ]; then
        echo "Error: Expected 5 arguments, received $#."
        echo "Usage: $0 [SUBSCRIPTION_ID] [LOCATION] [IMAGE_RESOURCE_GROUP_NAME] [IDENTITY_NAME] [GALLERY_NAME]"
        exit 1
    fi

    # Assign arguments to variables
    subscriptionId="$1"
    location="$2"
    resourceGroupName="$3"
    identityName="$4"
    galleryName="$5"

    # Define fixed variables for the resource group, virtual network, and subnet names.
    vnetName="Contoso-DevBox-vnet"
    subnetName="Contoso-DevBox-subnet"
    devCenterName="Contoso-DevBox-DevCenter"

    # Display planned actions for user clarity
    display_info

    # Create the Virtual Network and subnet
    echo "Creating Virtual Network: $vnetName and Subnet: $subnetName..."
    ./Vnet/deployVnet.sh "$resourceGroupName" "$location" "$vnetName" "$subnetName"
    check_exit_status "Error creating Virtual Network and Subnet."

    # Set up a network connection for Azure Development Center
    echo "Setting up Network Connection for Azure Development Center..."
    ./Vnet/createNetWorkConnection.sh "$location" "$subscriptionId" "$resourceGroupName" "$vnetName" "$subnetName"
    check_exit_status "Error setting up Network Connection for Azure Development Center."

    # Deploy the Azure Development Center
    echo "Deploying Azure Development Center..."
    ./DevBox/deployDevCenter.sh "$devCenterName" "$resourceGroupName" "$location" "$identityName" "$subscriptionId" "$galleryName" 
    check_exit_status "Error setting up Network Connection for Azure Development Center."

    # Create the DevBox project
    echo "Creating DevBox project..."
    ./DevBox/createDevBoxProject.sh "$location" "$subscriptionId" "$resourceGroupName" "$devCenterName" 
    check_exit_status "Error Creating DevBox project."

    # Display completion message
    cat <<- EOF
-----------------------------------------
Azure Resource Creation Completed!
-----------------------------------------
All operations completed successfully!
EOF
}

# Invoke the main function with all the passed arguments
main "$@"
