<#
.SYNOPSIS
This script assists users in logging into their Azure account and sets a specified subscription as active.
#>

# Exit on error
$ErrorActionPreference = 'Stop'

# Constants
$PROGNAME = $MyInvocation.MyCommand.Name

# Functions

# Display an error message and exit the script
function error_exit {
    param (
        [string]$Message = "Unknown Error"
    )
    
    Write-Error "$PROGNAME: $Message"
    exit 1
}

# Display the script usage instructions
function usage {
    Write-Host "Usage: $PROGNAME [SUBSCRIPTION_ID]"
    exit 1
}

# Main script execution

# Clear the terminal screen for a cleaner user experience
Clear-Host

Write-Host "Logging in to Azure"
Write-Host "-------------------"

# Ensure a subscription ID is provided; if not, display an error and usage message
if (-not $args[0]) {
    Write-Host "Error: Subscription ID not provided!"
    usage
}

$SUBSCRIPTION_ID = $args[0]

Write-Host "Target Subscription: $SUBSCRIPTION_ID"
Write-Host "-------------------"

# Prompt the user to log in and follow on-screen instructions
Write-Host "Please follow the on-screen instructions to log in."

try {
    az login
} catch {
    error_exit "Failed to log in to Azure."
}

# Attempt to set the provided subscription ID as the active subscription
Write-Host "Setting target subscription as active..."

try {
    az account set --subscription $SUBSCRIPTION_ID
} catch {
    error_exit "Failed to set target subscription."
}

Write-Host "-------------------"
Write-Host "Subscription set successfully!"
