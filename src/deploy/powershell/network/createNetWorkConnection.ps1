<#
.SYNOPSIS
    This script creates a network connection in Azure DevCenter.

.DESCRIPTION
    This script takes five parameters: the location, the network resource group name, the virtual network name, the subnet name, and the network connection name.
    It validates the input parameters, retrieves the subnet ID, and deploys the network connection.

.PARAMETER location
    The Azure location where the network connection will be created.

.PARAMETER networkResourceGroupName
    The name of the resource group where the virtual network is located.

.PARAMETER vnetName
    The name of the virtual network.

.PARAMETER subnetName
    The name of the subnet.

.PARAMETER networkConnectionName
    The name of the network connection to be created.

.EXAMPLE
    .\CreateNetworkConnection.ps1 -location "EastUS" -networkResourceGroupName "myResourceGroup" -vnetName "myVnet" -subnetName "mySubnet" -networkConnectionName "myNetworkConnection"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [string]$networkResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$vnetName,

    [Parameter(Mandatory = $true)]
    [string]$subnetName,

    [Parameter(Mandatory = $true)]
    [string]$networkConnectionName
)

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\CreateNetworkConnection.ps1 -location <location> -networkResourceGroupName <networkResourceGroupName> -vnetName <vnetName> -subnetName <subnetName> -networkConnectionName <networkConnectionName>"
    exit 1
}

# Function to validate input parameters
function Validate-Input {
    param (
        [string]$location,
        [string]$networkResourceGroupName,
        [string]$vnetName,
        [string]$subnetName,
        [string]$networkConnectionName
    )

    if (-not $location -or -not $networkResourceGroupName -or -not $vnetName -or -not $subnetName -or -not $networkConnectionName) {
        Write-Error "Error: All parameters are required."
        Show-Usage
    }
}

# Function to retrieve the subnet ID
function Get-SubnetId {
    param (
        [string]$networkResourceGroupName,
        [string]$vnetName,
        [string]$subnetName
    )

    Write-Host "Retrieving Subnet ID for $subnetName..."

    try {
        $subnetId = az network vnet subnet show `
            --resource-group $networkResourceGroupName `
            --vnet-name $vnetName `
            --name $subnetName `
            --query id `
            --output tsv

        if (-not $subnetId) {
            Write-Error "Error: Unable to retrieve the Subnet ID for $subnetName in $vnetName."
            exit 1
        }

        Write-Host "Subnet ID for $subnetName retrieved successfully."
        return $subnetId
    } catch {
        Write-Error "Error: Failed to retrieve Subnet ID."
        exit 1
    }
}

# Function to deploy the network connection
function Deploy-NetworkConnection {
    param (
        [string]$location,
        [string]$subnetId,
        [string]$networkConnectionName,
        [string]$networkResourceGroupName
    )

    Write-Host "Deploying Network Connection..."

    try {
        az devcenter admin network-connection create `
            --location $location `
            --domain-join-type "AzureADJoin" `
            --subnet-id $subnetId `
            --name $networkConnectionName `
            --resource-group $networkResourceGroupName

        Write-Host "Deployment initiated successfully."
    } catch {
        Write-Error "Error: Deployment failed."
        exit 1
    }
}

# Main function to create network connection
function Create-NetworkConnection {
    param (
        [string]$location,
        [string]$networkResourceGroupName,
        [string]$vnetName,
        [string]$subnetName,
        [string]$networkConnectionName
    )

    # Validate input parameters
    Validate-Input -location $location -networkResourceGroupName $networkResourceGroupName -vnetName $vnetName -subnetName $subnetName -networkConnectionName $networkConnectionName

    Write-Host "Initiating the deployment in the resource group: $networkResourceGroupName, location: $location."

    # Retrieve the subnet ID
    $subnetId = Get-SubnetId -networkResourceGroupName $networkResourceGroupName -vnetName $vnetName -subnetName $subnetName

    # Deploy the network connection
    Deploy-NetworkConnection -location $location -subnetId $subnetId -networkConnectionName $networkConnectionName -networkResourceGroupName $networkResourceGroupName

    Write-Host "Deployment completed successfully."
}

# Execute the main function with all script arguments
Create-NetworkConnection -location $location -networkResourceGroupName $networkResourceGroupName -vnetName $vnetName -subnetName $subnetName -networkConnectionName $networkConnectionName