<#
.SYNOPSIS
    This script registers Azure resource providers and adds the DevCenter extension.

.DESCRIPTION
    This script checks if the Azure CLI is installed, registers a list of Azure resource providers, and adds the DevCenter extension.

.PARAMETER None

.EXAMPLE
    .\RegisterFeatures.ps1
#>

# Exit immediately if a command exits with a non-zero status
$ErrorActionPreference = "Stop"

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\RegisterFeatures.ps1"
    exit 1
}

# Function to check if Azure CLI is installed
function Check-AzureCli {
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Error "Error: 'az' command is not found. Please ensure Azure CLI is installed."
        exit 1
    } else {
        Write-Host "'az' command is available. Continuing with the script..."
    }
}

# Function to register an Azure provider
function Register-AzureProvider {
    param (
        [string]$providerName
    )

    Write-Host "Starting registration for $providerName..."

    try {
        az provider register -n $providerName | Out-Null
        Write-Host "Successfully registered $providerName."
    } catch {
        Write-Error "Error: Failed to register $providerName."
        exit 1
    }
}

# Main function to register Azure resource providers
function Register-Features {
    Write-Host "Beginning Azure Resource Providers registration..."

    Check-AzureCli

    # List of Azure providers to register
    $azureProviders = @(
        "Microsoft.Storage"
        "Microsoft.Management"
        "Microsoft.DevCenter"
        "Microsoft.Compute"
        "Microsoft.DesktopVirtualization"
        "Microsoft.AAD"
        "Microsoft.GraphServices"
        "Microsoft.AzureActiveDirectory"
        "Microsoft.Network"
        "Microsoft.ManagedIdentity"
        "Microsoft.Security"
        "Microsoft.Monitor"
        "microsoft.aadiam"
        "Microsoft.Authorization"
        "Microsoft.Communication"
    )

    # Register each Azure provider
    foreach ($provider in $azureProviders) {
        Register-AzureProvider -providerName $provider
    }

    # Add the DevCenter extension
    Write-Host "Adding the 'devcenter' extension..."
    try {
        az extension add --name devcenter | Out-Null
        Write-Host "Successfully added the 'devcenter' extension."
    } catch {
        Write-Error "Error: Failed to add the 'devcenter' extension."
        exit 1
    }

    Write-Host "Azure Resource Providers registration process completed."
}

# Main script execution
function Main {
    Register-Features
}

# Execute the main function
Main