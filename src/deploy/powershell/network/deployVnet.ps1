#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script to create a virtual network and subnet in Azure.

.DESCRIPTION
    This script checks if the Azure CLI is installed, validates input parameters, and creates a virtual network and subnet in a specified resource group and location.

.PARAMETER NetworkResourceGroupName
    The name of the resource group containing the virtual network.

.PARAMETER Location
    The Azure region where the virtual network will be created.

.PARAMETER VnetName
    The name of the virtual network.

.PARAMETER SubnetName
    The name of the subnet within the virtual network.

.EXAMPLE
    .\deployVnet.ps1 -NetworkResourceGroupName "myResourceGroup" -Location "EastUS" -VnetName "myVnet" -SubnetName "mySubnet"
#>

# Constants
$Branch = "main"
$TemplateFileUri = "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$Branch/src/deploy/ARMTemplates/network/vNet/vNetTemplate.json"

# Function to display usage information
function Display-Usage {
    Write-Host "Usage: .\deployVnet.ps1 -NetworkResourceGroupName <networkResourceGroupName> -Location <location> -VnetName <vnetName> -SubnetName <subnetName>"
    exit 1
}

# Function to validate input parameters
function Validate-Parameters {
    param (
        [string]$NetworkResourceGroupName,
        [string]$Location,
        [string]$VnetName,
        [string]$SubnetName
    )

    if (-not $NetworkResourceGroupName -or -not $Location -or -not $VnetName -or -not $SubnetName) {
        Write-Host "Error: Missing required parameters."
        Display-Usage
    }
}

# Function to check if Azure CLI is installed
function Check-AzureCliInstalled {
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Host "Error: 'az' command is not found. Please ensure Azure CLI is installed."
        exit 1
    } else {
        Write-Host "'az' command is available. Continuing with the script..."
    }
}

# Function to create a virtual network and subnet
function Create-VirtualNetworkAndSubnet {
    param (
        [string]$NetworkResourceGroupName,
        [string]$Location,
        [string]$VnetName,
        [string]$SubnetName
    )

    $vnetAddressPrefix = "10.0.0.0/16"
    $subnetAddressPrefix = "10.0.0.0/24"

    Write-Host "Starting the creation of Virtual Network and Subnet..."
    Write-Host "Creating Virtual Network: $VnetName in Resource Group: $NetworkResourceGroupName with address prefix: $vnetAddressPrefix..."

    try {
        az deployment group create `
            --name $VnetName `
            --resource-group $NetworkResourceGroupName `
            --template-uri $TemplateFileUri `
            --parameters vNetName=$VnetName `
                         location=$Location `
                         vNetAddressPrefix=$vnetAddressPrefix `
                         subnetName=$SubnetName `
                         subnetAddressPrefix=$subnetAddressPrefix | Out-Null

        Write-Host "Virtual Network $VnetName and Subnet $SubnetName have been created successfully in Resource Group $NetworkResourceGroupName."
    }
    catch {
        Write-Host "Error: Failed to create Virtual Network and Subnet. $_"
        exit 1
    }
}

# Main script execution
param (
    [Parameter(Mandatory=$true)]
    [string]$NetworkResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [string]$VnetName,

    [Parameter(Mandatory=$true)]
    [string]$SubnetName
)

Check-AzureCliInstalled
Validate-Parameters -NetworkResourceGroupName $NetworkResourceGroupName -Location $Location -VnetName $VnetName -SubnetName $SubnetName
Create-VirtualNetworkAndSubnet -NetworkResourceGroupName $NetworkResourceGroupName -Location $Location -VnetName $VnetName -SubnetName $SubnetName