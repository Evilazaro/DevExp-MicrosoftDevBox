<#
    .SYNOPSIS
    This script helps users log in to their Azure account and set a specific subscription as active.
#>

# Function to handle errors and exit
function ErrorExit {
    param (
        [string]$ErrorMessage = "Unknown Error"
    )

    Write-Error -Message "$scriptName: $ErrorMessage"
    exit 1
}

# Constants
$scriptName = $PSCommandPath | Split-Path -Leaf

# Clear the terminal screen for better user experience.
Clear-Host

# Print a header to indicate the start of the Azure login process.
Write-Host "Logging in to Azure"
Write-Host "-------------------"

# Check if a subscription ID has been provided. If not, exit the script with a usage message.
if (-not $args[0]) {
    Write-Host "Error: Subscription ID not provided!"
    Write-Host "Usage: $scriptName [SUBSCRIPTION_ID]"
    exit 1
}

$SUBSCRIPTION_ID = $args[0]

# Display the subscription ID the user intends to set as active.
Write-Host "Target Subscription: $SUBSCRIPTION_ID"
Write-Host "-------------------"

# Prompt user to log in to their Azure account using the Azure CLI.
# They'll be redirected to a browser-based authentication process.
Write-Host "Please follow the on-screen instructions to log in."

try {
    az login
} catch {
    ErrorExit "Failed to log in to Azure."
}

# After successful login, set the specified subscription as the active subscription.
Write-Host "Setting target subscription as active..."

try {
    az account set --subscription $SUBSCRIPTION_ID
} catch {
    ErrorExit "Failed to set target subscription."
}

Write-Host "-------------------"
Write-Host "Subscription set successfully!"
