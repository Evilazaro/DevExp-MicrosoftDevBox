<#
.SYNOPSIS
    This script logs into Azure and sets the specified subscription.

.DESCRIPTION
    This script takes one parameter: the subscription ID.
    It logs into Azure using device code authentication and sets the specified subscription.

.PARAMETER subscriptionId
    The Azure subscription ID to set.

.EXAMPLE
    .\LoginToAzure.ps1 -subscriptionId "12345678-1234-1234-1234-123456789012"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$subscriptionId
)

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\LoginToAzure.ps1 -subscriptionId <subscriptionId>"
    Write-Host "Example: .\LoginToAzure.ps1 -subscriptionId '12345678-1234-1234-1234-123456789012'"
    exit 1
}

# Function to validate input parameters
function Validate-Parameters {
    param (
        [string]$subscriptionId
    )

    if (-not $subscriptionId) {
        Write-Error "Error: Invalid number of arguments."
        Show-Usage
    }
}

# Function to set the Azure subscription
function Set-AzureSubscription {
    param (
        [string]$subscriptionId
    )

    Write-Host "Attempting to set subscription to $subscriptionId..."

    try {
        az login --use-device-code
    } catch {
        Write-Error "Error: Failed to log in to Azure."
        exit 1
    }

    try {
        az account set --subscription $subscriptionId
        Write-Host "Successfully set Azure subscription to $subscriptionId."
    } catch {
        Write-Error "Error: Failed to set Azure subscription to $subscriptionId. Please check if the subscription ID is valid and you have access to it."
        exit 1
    }
}

# Main script execution
function Login-ToAzure {
    param (
        [string]$subscriptionId
    )

    Validate-Parameters -subscriptionId $subscriptionId
    Set-AzureSubscription -subscriptionId $subscriptionId
}

# Execute the main function with the script argument
Login-ToAzure -subscriptionId $subscriptionId