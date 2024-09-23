<#
.SYNOPSIS
    This script creates a virtual network and subnet in Azure.

.DESCRIPTION
    This script takes four parameters: the network resource group name, the location, the virtual network name, and the subnet name.
    It creates a virtual network and subnet using an ARM template.

.PARAMETER networkResourceGroupName
    The name of the resource group where the virtual network will be created.

.PARAMETER location
    The Azure location where the virtual network will be created.

.PARAMETER vnetName
    The name of the virtual network to be created.

.PARAMETER subnetName
    The name of the subnet to be created.

.EXAMPLE
    .\DeployVnet.ps1 -networkResourceGroupName "myResourceGroup" -location "EastUS" -vnetName "myVnet" -subnetName "mySubnet"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$networkResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [string]$vnetName,

    [Parameter(Mandatory = $true)]
    [string]$subnetName
)

# Constants
$branch = "main"
$templateFileUri = "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/network/vNet/vNetTemplate.json"

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\DeployVnet.ps1 -networkResourceGroupName <networkResourceGroupName> -location <location> -vnetName <vnetName> -subnetName <subnetName>"
    exit 1
}

# Function to ensure the correct number of arguments are passed
function Ensure-ArgumentsPassed {
    param (
        [int]$argumentCount
    )

    if ($argumentCount -ne 4) {
        Write-Error "Error: Invalid number of arguments."
        Show-Usage
    }
}

# Function to create a virtual network and subnet
function Create-VirtualNetworkAndSubnet {
    param (
        [string]$networkResourceGroupName,
        [string]$location,
        [string]$vnetName,
        [string]$subnetName
    )

    $vnetAddressPrefix = "10.0.0.0/16"

    Write-Host "Starting the creation of Virtual Network and Subnet..."
    Write-Host "Creating Virtual Network: $vnetName in Resource Group: $networkResourceGroupName with address prefix: $vnetAddressPrefix..."

    try {
        az deployment group create `
            --name $vnetName `
            --resource-group $networkResourceGroupName `
            --template-uri $templateFileUri `
            --parameters vNetName=$vnetName location=$location | Out-Null

        Write-Host "Virtual Network $vnetName and Subnet $subnetName have been created successfully in Resource Group $networkResourceGroupName."
    } catch {
        Write-Error "Error: Failed to create Virtual Network and Subnet."
        exit 1
    }
}

# Main script execution
function Deploy-Vnet {
    param (
        [string]$networkResourceGroupName,
        [string]$location,
        [string]$vnetName,
        [string]$subnetName
    )

    Ensure-ArgumentsPassed -argumentCount $PSCmdlet.MyInvocation.BoundParameters.Count
    Create-VirtualNetworkAndSubnet -networkResourceGroupName $networkResourceGroupName -location $location -vnetName $vnetName -subnetName $subnetName
}

# Execute the main function with all script arguments
Deploy-Vnet -networkResourceGroupName $networkResourceGroupName -location $location -vnetName $vnetName -subnetName $subnetName