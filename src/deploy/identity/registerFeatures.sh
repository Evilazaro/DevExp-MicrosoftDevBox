#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
# Treat unset variables as an error
set -o nounset
# Prevent errors in a pipeline from being masked
set -o pipefail

# Function to check if Azure CLI is installed
checkAzureCli() {
    if ! command -v az &> /dev/null; then
        echo "Error: 'az' command is not found. Please ensure Azure CLI is installed."
        exit 1
    else
        echo "'az' command is available. Continuing with the script..."
    fi
}

# Function to register an Azure provider
registerAzureProvider() {
    local providerName="$1"
    
    echo "Starting registration for $providerName..."
    
    if az provider register -n "$providerName"; then
        echo "Successfully registered $providerName."
    else
        echo "Error: Failed to register $providerName."
        exit 1
    fi
}

# Main function to register Azure resource providers
registerFeatures() {
    echo "Beginning Azure Resource Providers registration..."
    
    checkAzureCli

    # List of Azure providers to register
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

    # Register each Azure provider
    for provider in "${azureProviders[@]}"; do
        registerAzureProvider "$provider"
    done

    # Add the DevCenter extension
    if az extension add --name devcenter; then
        echo "Successfully added the 'devcenter' extension."
    else
        echo "Error: Failed to add the 'devcenter' extension."
        exit 1
    fi

    echo "Azure Resource Providers registration process completed."
}

# Execute the main function
registerFeatures