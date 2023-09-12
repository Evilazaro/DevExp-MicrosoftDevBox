#!/bin/bash

# Exit immediately if any command exits with a non-zero status, 
# treat unset variables as an error when substituting, 
# and ensure the pipeline's return status is the value of the last (rightmost) command to exit with a non-zero status.
set -e
set -o nounset
set -o pipefail

# Script Description:
# This script registers various Azure Resource Providers necessary for managing 
# and operating virtual machines, storage, networking, and other resources in Azure.

# Function to check the installation of Azure CLI
check_az_cli() {
    if ! command -v az &> /dev/null; then
        echo "Error: 'az' command is not found. Please ensure Azure CLI is installed."
        exit 1
    else
        echo "'az' command is available. Continuing with the script..."
    fi
}

# Function: register_provider
# Description: Registers an Azure provider and displays a corresponding message.
# Parameters:
#   1. Provider name
#   2. Provider description
register_provider() {
    local provider_name="$1"
    local description="$2"
    
    echo "Starting registration for $description..."
    
    if az provider register -n "$provider_name"; then
        echo "Successfully registered $description."
    else
        echo "Failed to register $description."
        exit 1  # Exit script upon registration failure to follow a 'fail fast' approach.
    fi
}

# Main script execution starts here
echo "Beginning Azure Resource Providers registration..."

# Check Azure CLI installation
check_az_cli

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
    # Split the string into name and description using array and the delimiter '|'
    IFS='|' read -ra parts <<< "$provider"
    register_provider "${parts[0]}" "${parts[1]}"
done

# Indicate the completion of the registration process
echo "Azure Resource Providers registration process completed."
