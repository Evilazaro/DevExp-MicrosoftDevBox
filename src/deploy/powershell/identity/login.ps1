#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script to log into Azure and set the subscription.

.DESCRIPTION
    This script logs into Azure using device code authentication and sets the specified subscription.

.PARAMETER SubscriptionId
    The Azure subscription ID to set.

.EXAMPLE
    .\login.ps1 -SubscriptionId "your-subscription-id"
#>

# Function to display usage information
function Display-Usage {
    Write-Host "Usage: .\login.ps1 -SubscriptionId <subscriptionId>"
    exit 1
}

# Function to validate input parameters
function Validate-Parameters {
    param (
        [string]$SubscriptionId
    )

    if (-not $SubscriptionId) {
        Write-Host "Error: Missing required parameter."
        Display-Usage
    }
}

# Function to log into Azure
function Log-IntoAzure {
    Write-Host "Attempting to log into Azure..."

    try {
        az login --use-device-code | Out-Null
        Write-Host "Successfully logged into Azure."
    }
    catch {
        Write-Host "Error: Failed to log into Azure. $_"
        exit 1
    }
}

# Function to set the Azure subscription
function Set-AzureSubscription {
    param (
        [string]$SubscriptionId
    )

    Write-Host "Attempting to set subscription to $SubscriptionId..."

    try {
        az account set --subscription $SubscriptionId | Out-Null
        Write-Host "Successfully set Azure subscription to $SubscriptionId."
    }
    catch {
        Write-Host "Error: Failed to set Azure subscription to $SubscriptionId. Please check if the subscription ID is valid and you have access to it. $_"
        exit 1
    }
}

# Main script execution
param (
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId
)

Validate-Parameters -SubscriptionId $SubscriptionId
Log-IntoAzure
Set-AzureSubscription -SubscriptionId $SubscriptionId