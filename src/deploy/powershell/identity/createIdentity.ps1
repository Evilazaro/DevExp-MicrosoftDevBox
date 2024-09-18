#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script to create an Azure identity.

.DESCRIPTION
    This script creates an Azure identity in a specified resource group and location.

.PARAMETER IdentityResourceGroupName
    The name of the resource group where the identity will be created.

.PARAMETER Location
    The Azure region where the identity will be created.

.PARAMETER IdentityName
    The name of the identity to be created.

.EXAMPLE
    .\createIdentity.ps1 -IdentityResourceGroupName "myResourceGroup" -Location "EastUS" -IdentityName "myIdentity"
#>

# Function to display usage information
function Display-Usage {
    Write-Host "Usage: .\createIdentity.ps1 -IdentityResourceGroupName <resourceGroupName> -Location <location> -IdentityName <identityName>"
    Write-Host "Example: .\createIdentity.ps1 -IdentityResourceGroupName 'myResourceGroup' -Location 'EastUS' -IdentityName 'myIdentity'"
    exit 1
}

# Function to validate input parameters
function Validate-Parameters {
    param (
        [string]$IdentityResourceGroupName,
        [string]$Location,
        [string]$IdentityName
    )

    if (-not $IdentityResourceGroupName -or -not $Location -or -not $IdentityName) {
        Write-Host "Error: Missing required parameters."
        Display-Usage
    }
}

# Function to create an Azure identity
function Create-AzureIdentity {
    param (
        [string]$IdentityResourceGroupName,
        [string]$Location,
        [string]$IdentityName
    )

    Write-Host "Creating identity '$IdentityName' in resource group '$IdentityResourceGroupName' located in '$Location'..."

    try {
        $output = az identity create --resource-group $IdentityResourceGroupName --name $IdentityName --location $Location -o json
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
    [string]$IdentityResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [string]$IdentityName
)

Validate-Parameters -IdentityResourceGroupName $IdentityResourceGroupName -Location $Location -IdentityName $IdentityName
Create-AzureIdentity -IdentityResourceGroupName $IdentityResourceGroupName -Location $Location -IdentityName $IdentityName