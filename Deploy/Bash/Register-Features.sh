#!/bin/bash

# Description:
# This script registers various Azure Resource Providers necessary for managing and operating virtual machines, storage, networking, and other resources in Azure.

# Define a function to register an Azure provider and display a corresponding message
register_provider() {
    local provider_name=$1
    local description=$2
    
    echo "Starting registration for $description..."
    az provider register -n $provider_name

    # Check if the operation was successful
    if [ $? -eq 0 ]; then
        echo "Successfully registered $description."
    else
        echo "Failed to register $description."
    fi
}

# Start of the script
echo "Beginning Azure Resource Providers registration..."

# Register each Azure Resource Provider with its description
register_provider "Microsoft.VirtualMachineImages" "Azure Resource Provider for Virtual Machine Images"
register_provider "Microsoft.Compute" "Azure Resource Provider for Compute"
register_provider "Microsoft.KeyVault" "Azure Resource Provider for Key Vault"
register_provider "Microsoft.Storage" "Azure Resource Provider for Storage"
register_provider "Microsoft.Network" "Azure Resource Provider for Network"

echo "Azure Resource Providers registration process completed."
