#!/bin/bash

set -e
set -o nounset
set -o pipefail

# Description:
# This script registers various Azure Resource Providers necessary for managing 
# and operating virtual machines, storage, networking, and other resources in Azure.

# Check for 'az' command dependencies
if ! command -v az &>/dev/null; then
    echo "Error: 'az' command is not found. Please ensure Azure CLI is installed."
    exit 1
fi

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
        exit 1  # Consider exiting upon failure for 'fail fast' approach.
    fi
}

# Start of the script's main execution
echo "Beginning Azure Resource Providers registration..."

# Register each Azure Resource Provider with its description
providers=(
    "Microsoft.VirtualMachineImages Azure Resource Provider for Virtual Machine Images"
    "Microsoft.Compute Azure Resource Provider for Compute"
    "Microsoft.KeyVault Azure Resource Provider for Key Vault"
    "Microsoft.Storage Azure Resource Provider for Storage"
    "Microsoft.Network Azure Resource Provider for Network"
)

for provider in "${providers[@]}"; do
    # Split the string into name and description using array
    IFS=' ' read -ra parts <<< "$provider"
    register_provider "${parts[0]}" "${parts[@]:1}"
done

echo "Azure Resource Providers registration process completed."
