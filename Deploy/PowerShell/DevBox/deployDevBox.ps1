<#
.SYNOPSIS
This script automates the creation of an Azure Resource Group, a Virtual Network (VNet) inside that Resource Group,
and sets up a network connection for Azure Development Center with domain-join capabilities.
#>

function Display-Info {
    $output = @"
-----------------------------------------
Azure Resource Automation Script
-----------------------------------------
Subscription ID: $subscriptionId
Resource Group: $devBoxResourceGroupName
Location: $location
VNet Name: $vnetName
Subnet Name: $subnetName
-----------------------------------------
"@
    Write-Output $output
}

function Main {
    param (
        [string]$subscriptionId,
        [string]$location,
        [string]$frontEndImageName,
        [string]$backEndImageName,
        [string]$imageResourceGroupName
    )

    # Check for required arguments
    if (-not ($subscriptionId) -or -not ($location) -or -not ($frontEndImageName) -or -not ($backEndImageName) -or -not ($imageResourceGroupName)) {
        Write-Error "Usage: [ScriptName] -subscriptionId [SUBSCRIPTION_ID] -location [LOCATION] -frontEndImageName [FRONT_END_IMAGE_NAME] -backEndImageName [BACK_END_IMAGE_NAME] -imageResourceGroupName [IMAGE_RESOURCE_GROUP_NAME]"
        exit 1
    }

    # Define fixed variables for the resource group, virtual network, and subnet names.
    $devBoxResourceGroupName = "Contoso-DevBox-rg"
    $vnetName = "Contoso-DevBox-vnet"
    $subnetName = "Contoso-DevBox-subnet"

    # Display planned actions for user clarity
    Display-Info

    # Create a new resource group using the Azure CLI
    Write-Output "Creating Resource Group: $devBoxResourceGroupName in location: $location..."
    az group create -n $devBoxResourceGroupName -l $location

    # Check for any errors after running Azure CLI command
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error creating Resource Group."
        exit 1
    }

    # Create the Virtual Network and subnet
    Write-Output "Creating Virtual Network: $vnetName and Subnet: $subnetName..."
    & .\Vnet\deployVnet.ps1 $devBoxResourceGroupName $location $vnetName $subnetName

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error creating Virtual Network and Subnet."
        exit 1
    }

    # Set up a network connection for Azure Development Center
    Write-Output "Setting up Network Connection for Azure Development Center..."
    & .\Vnet\createNetWorkConnection.ps1 $location $subscriptionId $devBoxResourceGroupName $vnetName $subnetName

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error setting up Network Connection for Azure Development Center."
        exit 1
    }

    Write-Output @"
-----------------------------------------
Azure Resource Creation Completed!
-----------------------------------------
All operations completed successfully!
"@
}

# Invoke the main function
Main -subscriptionId $args[0] -location $args[1] -frontEndImageName $args[2] -backEndImageName $args[3] -imageResourceGroupName $args[4]
