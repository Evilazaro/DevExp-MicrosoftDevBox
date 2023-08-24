# Azure Resource Automation Script in PowerShell

function Display-Info {
    Write-Host "-----------------------------------------"
    Write-Host "Azure Resource Automation Script"
    Write-Host "-----------------------------------------"
    Write-Host "Subscription ID: $subscriptionId"
    Write-Host "Resource Group: $devBoxResourceGroupName"
    Write-Host "Location: $location"
    Write-Host "VNet Name: $vnetName"
    Write-Host "Subnet Name: $subnetName"
    Write-Host "-----------------------------------------"
}

# Ensure necessary arguments are provided
if ($args.Count -lt 5) {
    Write-Host "Error: Expected 5 arguments, received $($args.Count)."
    Write-Host "Usage: ./script_name.ps1 [SUBSCRIPTION_ID] [LOCATION] [FRONT_END_IMAGE_NAME] [BACK_END_IMAGE_NAME] [IMAGE_RESOURCE_GROUP_NAME]"
    exit 1
}

# Assign arguments to variables
$subscriptionId = $args[0]
$location = $args[1]
$frontEndImageName = $args[2]
$backEndImageName = $args[3]
$imageResourceGroupName = $args[4]

# Define fixed variables for the resource group, location, virtual network, and subnet names.
$devBoxResourceGroupName = "Contoso-DevBox-rg"
$vnetName = "Contoso-AzureDevBox-vnet"
$subnetName = "Contoso-AzureDevBox-subnet"

# Display planned actions for user clarity
Display-Info

# Create a new resource group using the Azure CLI
Write-Host "Creating Resource Group: $devBoxResourceGroupName in location: $location..."
az group create -n $devBoxResourceGroupName -l $location

# Create the Virtual Network and subnet
Write-Host "Creating Virtual Network: $vnetName and Subnet: $subnetName..."
& ".\Vnet\deployVnet.ps1" $devBoxResourceGroupName $location $vnetName $subnetName

# Set up a network connection for Azure Development Center
Write-Host "Setting up Network Connection for Azure Development Center..."
& ".\Vnet\createNetWorkConnection.ps1" $location $subscriptionId $devBoxResourceGroupName $vnetName $subnetName

Write-Host "-----------------------------------------"
Write-Host "Azure Resource Creation Completed!"
Write-Host "-----------------------------------------"

Write-Host "All operations completed successfully!"
