# This script creates an Azure Virtual Network and Subnet within a specified Resource Group.

# Exit if any command fails
$ErrorActionPreference = "Stop"

# Check if az CLI is installed
if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
    Write-Host "az CLI could not be found. Please install it before running this script."
    exit
}

# Ensure required arguments are passed
if ($args.Length -ne 4) {
    Write-Host "Usage: .\$($MyInvocation.MyCommand) <Resource Group Name> <Location> <VNet Name> <Subnet Name>"
    exit 1
}

# Assign arguments to meaningful variable names with comments.
$resourceGroupName = $args[0] # Name of the resource group.
$location = $args[1]          # Azure Region location where the resources will be created.
$vnetName = $args[2]          # Name of the virtual network.
$subnetName = $args[3]        # Name of the subnet to be created within the virtual network.

# Declare additional variables with comments.
$vnetAddressPrefix = "10.0.0.0/16" # Address prefix for the virtual network.
$subnetAddressPrefix = "10.0.0.0/24" # Address prefix for the subnet within the virtual network.

# Inform the user about the start of the process.
Write-Host "Starting the creation of Virtual Network and Subnet..."

# Create the Virtual Network and Subnet using the Azure CLI.
Write-Host "Creating Virtual Network: $vnetName in Resource Group: $resourceGroupName with address prefix: $vnetAddressPrefix..."
az network vnet create `
    --resource-group $resourceGroupName `
    --location $location `
    --name $vnetName `
    --address-prefix $vnetAddressPrefix `
    --subnet-name $subnetName `
    --subnet-prefix $subnetAddressPrefix `
    --tags "division=Contoso-Platform" "Environment=Prod" "offer=Contoso-DevWorkstation-Service" "Team=Engineering" "division=Contoso-Platform" "solution=eShop"

# Inform the user that the resources have been created successfully.
Write-Host "Virtual Network $vnetName and Subnet $subnetName have been created successfully in Resource Group $resourceGroupName."
