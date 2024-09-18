#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script to create an Azure identity.

.DESCRIPTION
    This script creates an Azure identity in a specified resource group and location.

.PARAMETER ResourceGroupName
    The name of the resource group.

.PARAMETER Location
    The Azure region where the identity will be created.

.PARAMETER IdentityName
    The name of the identity to be created.

.EXAMPLE
    .\createIdentity.ps1 -ResourceGroupName "myResourceGroup" -Location "EastUS" -IdentityName "myIdentity"
#>

# Function to display usage information
function Display-Usage {
    Write-Host "Usage: .\createIdentity.ps1 -ResourceGroupName <resourceGroupName> -Location <location> -IdentityName <identityName>"
    Write-Host "Example: .\createIdentity.ps1 -ResourceGroupName 'myResourceGroup' -Location 'EastUS' -IdentityName 'myIdentity'"
    exit 1
}

# Function to validate input parameters
function Validate-Parameters {
    param (
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$IdentityName
    )

    if (-not $ResourceGroupName -or -not $Location -or -not $IdentityName) {
        Write-Host "Error: Missing required parameters."
        Display-Usage
    }
}

# Function to create an Azure identity
function Create-AzureIdentity {
    param (
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$IdentityName
    )

    Write-Host "Creating identity '$IdentityName' in resource group '$ResourceGroupName' located in '$Location'..."

    try {
        $output = az identity create --resource-group $ResourceGroupName --name $IdentityName --location $Location -o json
        Write-Host "Identity '$IdentityName' successfully created."
    }
    catch {
        Write-Host "Error occurred while creating identity '$IdentityName': $_"
        exit 1
    }
}

# Main script execution
param (
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [string]$IdentityName
)

Validate-Parameters -ResourceGroupName $ResourceGroupName -Location $Location -IdentityName $IdentityName
Create-AzureIdentity -ResourceGroupName $ResourceGroupName -Location $Location -IdentityName $IdentityName