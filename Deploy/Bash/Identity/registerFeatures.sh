#!/bin/bash

set -e
set -o nounset
set -o pipefail

# Function to check the installation of Azure CLI
function checkAzCli() {
    if ! command -v az &> /dev/null; then
        echo "Error: 'az' command is not found. Please ensure Azure CLI is installed."
        exit 1
    else
        echo "'az' command is available. Continuing with the script..."
    fi
}

# Function to register an Azure provider and display a corresponding message.
function registerProvider() {
    local providerName="$1"
    local description="$2"
    
    echo "Starting registration for $description..."
    
    if az provider register -n "$providerName"; then
        echo "Successfully registered $description."
    else
        echo "Failed to register $description."
        exit 1
    fi
}

echo "Beginning Azure Resource Providers registration..."

# Check Azure CLI installation
checkAzCli

# Define an array with providers and their descriptions
providers=(
    "Microsoft.VirtualMachineImages|Azure Resource Provider for Virtual Machine Images"
    "Microsoft.Compute|Azure Resource Provider for Compute"
    "Microsoft.KeyVault|Azure Resource Provider for Key Vault"
    "Microsoft.Storage|Azure Resource Provider for Storage"
    "Microsoft.Network|Azure Resource Provider for Network"
    "Microsoft.DevCenter|Azure Resource Provider for Dev Center"
)

# Loop through each provider and initiate the registration process
for provider in "${providers[@]}"; do
    IFS='|' read -ra parts <<< "$provider"
    registerProvider "${parts[0]}" "${parts[1]}"
done

az extension add --name devcenter

echo "Azure Resource Providers registration process completed."
