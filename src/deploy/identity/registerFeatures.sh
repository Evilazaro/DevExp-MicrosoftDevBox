#!/bin/bash

set -e
set -o nounset
set -o pipefail

# Check if Azure CLI is installed.
checkAzureCli() {
    if ! command -v az &> /dev/null; then
        echo "Error: 'az' command is not found. Please ensure Azure CLI is installed."
        exit 1
    else
        echo "'az' command is available. Continuing with the script..."
    fi
}

# Register a given Azure provider.
registerAzureProvider() {
    local providerName="$1"
    local providerDescription="$2"
    
    echo "Starting registration for $providerDescription..."
    
    if az provider register -n "$providerName"; then
        echo "Successfully registered $providerDescription."
    else
        echo "Failed to register $providerDescription."
        exit 1
    fi
}

main() {
    echo "Beginning Azure Resource Providers registration..."
    
    # Check Azure CLI installation
    checkAzureCli

    # Define providers and their descriptions
    local azureProviders=(
        "Microsoft.VirtualMachineImages"
        "Microsoft.Compute"
        "Microsoft.KeyVault"
        "Microsoft.Storage"
        "Microsoft.Network"
        "Microsoft.DevCenter"
        "Microsoft.ContainerInstance"
        "Microsoft.GraphServices"
        "Microsoft.AAD"
        "Microsoft.AzureActiveDirectory"
        "Microsoft.EnterpriseSupport"
        "microsoft.support"
        "Microsoft.DesktopVirtualization"
        "Microsoft.Monitor"
    )
    local providerDescriptions=(
        "Azure Resource Provider for Virtual Machine Images"
        "Azure Resource Provider for Compute"
        "Azure Resource Provider for Key Vault"
        "Azure Resource Provider for Storage"
        "Azure Resource Provider for Network"
        "Azure Resource Provider for Dev Center"
        "Azure Resource Provider for Container Instance"
        "Azure Resource Provider for Graph"
        "Azure Resource Provider for AAD"
        "Azure Resource Provider for Azure Active Directory"
        "Azure Resource Provider for Enterprise Support"
        "Azure Resource Provider for Support"
        "Azure Resource Provider for Virtual Desktop"
        "Azure Resource Provider for Monitor"
    )

    # Register each provider
    for index in "${!azureProviders[@]}"; do
        registerAzureProvider "${azureProviders[$index]}" "${providerDescriptions[$index]}"
    done

    # Add devcenter extension
    az extension add --name devcenter

    echo "Azure Resource Providers registration process completed."
}

# Execute the main function
main
