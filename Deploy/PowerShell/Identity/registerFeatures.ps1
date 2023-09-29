# Abort the script when a command fails
$ErrorActionPreference = "Stop"

# Function to check the installation of Azure CLI
function Check-AzCli {
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Output "Error: 'az' command is not found. Please ensure Azure CLI is installed."
        exit 1
    } else {
        Write-Output "'az' command is available. Continuing with the script..."
    }
}

# Function to register an Azure provider and display a corresponding message.
function Register-Provider {
    param (
        [string]$providerName,
        [string]$description
    )

    Write-Output "Starting registration for $description..."

    try {
        az provider register -n $providerName
        Write-Output "Successfully registered $description."
    } catch {
        Write-Output "Failed to register $description."
        exit 1
    }
}

Write-Output "Beginning Azure Resource Providers registration..."

# Check Azure CLI installation
Check-AzCli

# Define a list with providers and their descriptions
$providers = @(
    "Microsoft.VirtualMachineImages|Azure Resource Provider for Virtual Machine Images",
    "Microsoft.Compute|Azure Resource Provider for Compute",
    "Microsoft.KeyVault|Azure Resource Provider for Key Vault",
    "Microsoft.Storage|Azure Resource Provider for Storage",
    "Microsoft.Network|Azure Resource Provider for Network",
    "Microsoft.DevCenter|Azure Resource Provider for Dev Center"
)

# Loop through each provider and initiate the registration process
foreach ($provider in $providers) {
    $parts = $provider -split '\|'
    Register-Provider -providerName $parts[0] -description $parts[1]
}

az extension add --name devcenter

Write-Output "Azure Resource Providers registration process completed."
