#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script to register Azure resource providers and add the DevCenter extension.

.DESCRIPTION
    This script checks if the Azure CLI is installed, registers a list of Azure resource providers, and adds the DevCenter extension.

.EXAMPLE
    .\registerFeatures.ps1
#>

# Function to check if Azure CLI is installed
function Check-AzureCli {
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Host "Error: 'az' command is not found. Please ensure Azure CLI is installed."
        exit 1
    } else {
        Write-Host "'az' command is available. Continuing with the script..."
    }
}

# Function to register an Azure provider
function Register-AzureProvider {
    param (
        [string]$ProviderName
    )

    Write-Host "Starting registration for $ProviderName..."

    try {
        az provider register -n $ProviderName | Out-Null
        Write-Host "Successfully registered $ProviderName."
    }
    catch {
        Write-Host "Error: Failed to register $ProviderName. $_"
        exit 1
    }
}

# Main function to register Azure resource providers
function Register-Features {
    Write-Host "Beginning Azure Resource Providers registration..."

    Check-AzureCli

    # List of Azure providers to register
    $azureProviders = @(
        "Microsoft.Storage",
        "Microsoft.Management",
        "Microsoft.DevCenter",
        "Microsoft.Compute",
        "Microsoft.VirtualMachineImages",
        "Microsoft.Web",
        "Microsoft.CloudShell",
        "Microsoft.AppConfiguration",
        "Microsoft.DesktopVirtualization",
        "Microsoft.AAD",
        "Microsoft.GraphServices",
        "Microsoft.AzureActiveDirectory",
        "Microsoft.Network",
        "Microsoft.OperationsManagement",
        "Microsoft.ManagedIdentity",
        "Microsoft.Security",
        "Microsoft.Monitor",
        "GitHub.Network",
        "microsoft.aadiam",
        "Microsoft.Authorization",
        "Microsoft.Communication",
        "Microsoft.Devices",
        "Microsoft.DeviceRegistry",
        "Microsoft.DeviceUpdate",
        "Microsoft.Migrate",
        "Microsoft.ResourceGraph",
        "Microsoft.Resources",
        "Microsoft.Subscription",
        "Microsoft.WorkloadBuilder",
        "Microsoft.Workloads"
    )

    # Register each Azure provider
    foreach ($provider in $azureProviders) {
        Register-AzureProvider -ProviderName $provider
    }

    # Add the DevCenter extension
    try {
        az extension add --name devcenter | Out-Null
        Write-Host "Successfully added the 'devcenter' extension."
    }
    catch {
        Write-Host "Error: Failed to add the 'devcenter' extension. $_"
        exit 1
    }

    Write-Host "Azure Resource Providers registration process completed."
}

# Execute the main function
Register-Features