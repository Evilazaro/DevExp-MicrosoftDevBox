<#
.SYNOPSIS
This script creates a Virtual Network (VNet) and a subnet within that VNet in Azure.

.DESCRIPTION
It expects four arguments: Resource Group Name, Azure Region, VNet Name, and Subnet Name.
#>

# Constants
$SCRIPT_NAME = $MyInvocation.MyCommand.Name
$ADDRESS_PREFIX = "10.0.0.0/16"
$SUBNET_PREFIX = "10.0.1.0/24"

# Function to display a usage message when the script is not executed correctly.
function Usage {
    Write-Host "Usage: $SCRIPT_NAME <RESOURCE_GROUP_NAME> <AZURE_REGION> <VNET_NAME> <SUBNET_NAME>"
    exit 1
}

# Check for the correct number of arguments.
if ($args.Length -ne 4) {
    Write-Host "Error: Incorrect number of arguments provided."
    Usage
}

# Assign arguments to meaningful variable names.
$resourceGroupName = $args[0]
$location = $args[1]
$vnetName = $args[2]
$subnetName = $args[3]

# Display the operation details.
Write-Host @"
----------------------------------
       Creating VNet in Azure      
----------------------------------
Resource Group Name: $resourceGroupName
Azure Region/Location: $location
Virtual Network Name: $vnetName
Subnet Name: $subnetName
----------------------------------
"@

# Informing the user about the upcoming operation.
Write-Host "Initiating the creation of the VNet and subnet..."

# Create the Virtual Network and Subnet using the Azure CLI.
az network vnet create `
    --resource-group $resourceGroupName `
    --name $vnetName `
    --address-prefix $ADDRESS_PREFIX `
    --subnet-name $subnetName `
    --subnet-prefix $SUBNET_PREFIX

# Confirming the successful creation of the VNet and subnet.
Write-Host "Success: Virtual Network '$vnetName' and Subnet '$subnetName' have been created."
