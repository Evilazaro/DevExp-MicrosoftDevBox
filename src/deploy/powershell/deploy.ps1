<#
.SYNOPSIS
    This script creates an Azure resource group, storage account, and blob container.

.DESCRIPTION
    This script takes four parameters: resource group name, location, storage account name, and container name.
    It creates a resource group, storage account, retrieves the storage account key, and creates a blob container.

.PARAMETER resourceGroupName
    The name of the resource group to be created.

.PARAMETER location
    The Azure location where the resources will be created.

.PARAMETER storageAccountName
    The name of the storage account to be created.

.PARAMETER containerName
    The name of the blob container to be created.

.EXAMPLE
    .\Deploy.ps1 -resourceGroupName "myResourceGroup" -location "EastUS" -storageAccountName "mystorageaccount" -containerName "mycontainer"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [string]$storageAccountName,

    [Parameter(Mandatory = $true)]
    [string]$containerName
)

# Function to create a resource group
function Create-ResourceGroup {
    param (
        [string]$resourceGroupName,
        [string]$location
    )

    Write-Host "Creating resource group: $resourceGroupName in location: $location..."
    try {
        az group create --name $resourceGroupName --location $location | Out-Null
        Write-Host "Resource group $resourceGroupName created successfully."
    } catch {
        Write-Error "Error: Failed to create resource group $resourceGroupName."
        exit 1
    }
}

# Function to create a storage account
function Create-StorageAccount {
    param (
        [string]$storageAccountName,
        [string]$resourceGroupName,
        [string]$location
    )

    Write-Host "Creating storage account: $storageAccountName in resource group: $resourceGroupName..."
    try {
        az storage account create --name $storageAccountName --resource-group $resourceGroupName --location $location --sku Standard_LRS | Out-Null
        Write-Host "Storage account $storageAccountName created successfully."
    } catch {
        Write-Error "Error: Failed to create storage account $storageAccountName."
        exit 1
    }
}

# Function to retrieve the storage account key
function Get-StorageAccountKey {
    param (
        [string]$storageAccountName,
        [string]$resourceGroupName
    )

    Write-Host "Retrieving storage account key for: $storageAccountName..."
    try {
        $accountKey = az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query '[0].value' --output tsv
        if (-not $accountKey) {
            Write-Error "Error: Failed to retrieve storage account key for $storageAccountName."
            exit 1
        }
        Write-Host "Storage account key retrieved successfully."
        return $accountKey
    } catch {
        Write-Error "Error: Failed to retrieve storage account key for $storageAccountName."
        exit 1
    }
}

# Function to create a blob container
function Create-BlobContainer {
    param (
        [string]$containerName,
        [string]$storageAccountName,
        [string]$accountKey
    )

    Write-Host "Creating blob container: $containerName in storage account: $storageAccountName..."
    try {
        az storage container create --name $containerName --account-name $storageAccountName --account-key $accountKey | Out-Null
        Write-Host "Blob container $containerName created successfully."
    } catch {
        Write-Error "Error: Failed to create blob container $containerName."
        exit 1
    }
}

# Main script execution
function Deploy-Resources {
    param (
        [string]$resourceGroupName,
        [string]$location,
        [string]$storageAccountName,
        [string]$containerName
    )

    Create-ResourceGroup -resourceGroupName $resourceGroupName -location $location
    Create-StorageAccount -storageAccountName $storageAccountName -resourceGroupName $resourceGroupName -location $location
    $accountKey = Get-StorageAccountKey -storageAccountName $storageAccountName -resourceGroupName $resourceGroupName
    Create-BlobContainer -containerName $containerName -storageAccountName $storageAccountName -accountKey $accountKey
}

# Execute the main function with all script arguments
Deploy-Resources -resourceGroupName $resourceGroupName -location $location -storageAccountName $storageAccountName -containerName $containerName