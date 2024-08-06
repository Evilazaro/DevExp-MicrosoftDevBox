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
    
    echo "Starting registration for $providerName..."
    
    if az provider register -n "$providerName"; then
        echo "Successfully registered $providerName."
    else
        echo "Failed to register $providerName."
        exit 1
    fi
}

main() {
    echo "Beginning Azure Resource Providers registration..."
    
    # Check Azure CLI installation
    checkAzureCli

    # Define providers and their descriptions
    local azureProviders=(
    "Microsoft.Storage"
    "Microsoft.Management"
    "Microsoft.DevCenter"
    "Microsoft.Compute"
    "Microsoft.VirtualMachineImages"
    "Microsoft.Web"
    "Microsoft.CloudShell"
    "Microsoft.AppConfiguration"
    "Microsoft.ContainerInstance"
    "Microsoft.DesktopVirtualization"
    "Microsoft.AAD"
    "Microsoft.GraphServices"
    "Microsoft.AzureActiveDirectory"
    "Microsoft.EnterpriseSupport"
    "Microsoft.ContainerRegistry"
    "Microsoft.ContainerService"
    "Microsoft.ManagedServices"
    "Microsoft.Network"
    "Microsoft.OperationsManagement"
    "Microsoft.ManagedIdentity"
    "Microsoft.Security"
    "Microsoft.Dashboard"
    "Microsoft.Monitor"
    "GitHub.Network"
    "microsoft.aadiam"
    "Microsoft.AnyBuild"
    "Microsoft.ApiCenter"
    "Microsoft.App"
    "Microsoft.AppAssessment"
    "Microsoft.AppComplianceAutomation"
    "Microsoft.AppPlatform"
    "Microsoft.AppSecurity"
    "Microsoft.Authorization"
    "Microsoft.Communication"
    "Microsoft.Devices"
    "Microsoft.DeviceRegistry"
    "Microsoft.DeviceUpdate"
    "Microsoft.Migrate"
    "Microsoft.ResourceGraph"
    "Microsoft.Resources"
    "Microsoft.SerialConsole"
    "Microsoft.ServiceFabric"
    "Microsoft.ServiceFabricMesh"
    "Microsoft.SqlVirtualMachine"
    "Microsoft.Subscription"
    "microsoft.visualstudio"
    "Microsoft.WorkloadBuilder"
    "Microsoft.Workloads"
)

    # Register each provider
    for index in "${!azureProviders[@]}"; do
        registerAzureProvider "${azureProviders[$index]}"
    done

    # Add devcenter extension
    az extension add --name devcenter

    echo "Azure Resource Providers registration process completed."
}

# Execute the main function
main
