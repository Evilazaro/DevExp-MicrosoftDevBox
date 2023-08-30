# Description:
# This script registers various Azure Resource Providers necessary for managing 
# and operating virtual machines, storage, networking, and other resources in Azure.

# Check for 'az' command dependencies
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Error: 'az' command is not found. Please ensure Azure CLI is installed."
    exit 1
}

# Function: Register-Provider
# Description: Registers an Azure provider and displays a corresponding message.
# Parameters:
#   1. Provider name
#   2. Provider description
function Register-Provider {
    param (
        [Parameter(Mandatory=$true)][string]$providerName,
        [Parameter(Mandatory=$true)][string]$description
    )
    
    Write-Host "Starting registration for $description..."
    
    if (az provider register -n $providerName) {
        Write-Host "Successfully registered $description."
    } else {
        Write-Host "Failed to register $description."
        exit 1  # Consider exiting upon failure for 'fail fast' approach.
    }
}

# Start of the script's main execution
Write-Host "Beginning Azure Resource Providers registration..."

# Register each Azure Resource Provider with its description
$providers = @(
    "Microsoft.VirtualMachineImages Azure Resource Provider for Virtual Machine Images",
    "Microsoft.Compute Azure Resource Provider for Compute",
    "Microsoft.KeyVault Azure Resource Provider for Key Vault",
    "Microsoft.Storage Azure Resource Provider for Storage",
    "Microsoft.Network Azure Resource Provider for Network"
)

foreach ($provider in $providers) {
    # Split the string into name and description
    $parts = $provider -split ' ', 2
    Register-Provider -providerName $parts[0] -description $parts[1]
}

Write-Host "Azure Resource Providers registration process completed."
