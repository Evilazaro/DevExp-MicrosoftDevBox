#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script to deploy a network connection in Azure.

.DESCRIPTION
    This script retrieves the Subnet ID and deploys a network connection in a specified resource group and location.

.PARAMETER Location
    The Azure region where the network connection will be deployed.

.PARAMETER NetworkResourceGroupName
    The name of the resource group containing the virtual network.

.PARAMETER VnetName
    The name of the virtual network.

.PARAMETER SubNetName
    The name of the subnet within the virtual network.

.PARAMETER NetworkConnectionName
    The name of the network connection to be created.

.EXAMPLE
    .\createNetworkConnection.ps1 -Location "EastUS" -NetworkResourceGroupName "myResourceGroup" -VnetName "myVnet" -SubNetName "mySubnet" -NetworkConnectionName "myNetworkConnection"
#>

# Function to display usage information
function Display-Usage {
    Write-Host "Usage: .\createNetworkConnection.ps1 -Location <location> -NetworkResourceGroupName <networkResourceGroupName> -VnetName <vnetName> -SubNetName <subNetName> -NetworkConnectionName <networkConnectionName>"
    exit 1
}

# Function to validate input parameters
function Validate-Parameters {
    param (
        [string]$Location,
        [string]$NetworkResourceGroupName,
        [string]$VnetName,
        [string]$SubNetName,
        [string]$NetworkConnectionName
    )

    if (-not $Location -or -not $NetworkResourceGroupName -or -not $VnetName -or -not $SubNetName -or -not $NetworkConnectionName) {
        Write-Host "Error: Missing required parameters."
        Display-Usage
    }
}

# Function to retrieve the Subnet ID
function Get-SubnetId {
    param (
        [string]$NetworkResourceGroupName,
        [string]$VnetName,
        [string]$SubNetName
    )

    Write-Host "Retrieving Subnet ID for $SubNetName in VNet $VnetName..."

    try {
        $subnetId = az network vnet subnet show `
            --resource-group $NetworkResourceGroupName `
            --vnet-name $VnetName `
            --name $SubNetName `
            --query id `
            --output tsv

        if (-not $subnetId) {
            Write-Host "Error: Unable to retrieve the Subnet ID for $SubNetName in VNet $VnetName."
            exit 1
        }

        Write-Host "Subnet ID for $SubNetName retrieved successfully: $subnetId"
        return $subnetId
    }
    catch {
        Write-Host "Error: Failed to retrieve Subnet ID. $_"
        exit 1
    }
}

# Function to deploy the network connection
function Deploy-NetworkConnection {
    param (
        [string]$Location,
        [string]$NetworkResourceGroupName,
        [string]$NetworkConnectionName,
        [string]$SubnetId
    )

    Write-Host "Deploying Network Connection $NetworkConnectionName in Resource Group $NetworkResourceGroupName..."

    try {
        az devcenter admin network-connection create `
            --location $Location `
            --domain-join-type "AzureADJoin" `
            --subnet-id $SubnetId `
            --name $NetworkConnectionName `
            --resource-group $NetworkResourceGroupName | Out-Null

        Write-Host "Network Connection $NetworkConnectionName deployed successfully."
    }
    catch {
        Write-Host "Error: Failed to deploy Network Connection $NetworkConnectionName. $_"
        exit 1
    }
}

# Main script execution
param (
    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [string]$NetworkResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$VnetName,

    [Parameter(Mandatory=$true)]
    [string]$SubNetName,

    [Parameter(Mandatory=$true)]
    [string]$NetworkConnectionName
)

Validate-Parameters -Location $Location -NetworkResourceGroupName $NetworkResourceGroupName -VnetName $VnetName -SubNetName $SubNetName -NetworkConnectionName $NetworkConnectionName

Write-Host "Initiating the deployment in Resource Group: $NetworkResourceGroupName, Location: $Location."

$subnetId = Get-SubnetId -NetworkResourceGroupName $NetworkResourceGroupName -VnetName $VnetName -SubNetName $SubNetName

Deploy-NetworkConnection -Location $Location -NetworkResourceGroupName $NetworkResourceGroupName -NetworkConnectionName $NetworkConnectionName -SubnetId $subnetId