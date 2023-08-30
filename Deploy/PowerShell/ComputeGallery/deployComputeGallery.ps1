<#
.SYNOPSIS
Creates a resource in Azure using provided details.

.DESCRIPTION
This script uses Azure CLI to create a Shared Image Gallery (SIG) resource 
with given gallery name, location, and resource group.

.PARAMETER galleryName
Name of the gallery.

.PARAMETER location
Azure location (e.g., eastus).

.PARAMETER galleryResourceGroup
Name of the resource group in Azure.

.EXAMPLE
.\scriptname.ps1 -galleryName "myGallery" -location "eastus" -galleryResourceGroup "myResourceGroup"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$galleryName,

    [Parameter(Mandatory=$true)]
    [string]$location,

    [Parameter(Mandatory=$true)]
    [string]$galleryResourceGroup
)

# Function to display the usage of the script
function usage {
    Write-Host "Usage: .\$($MyInvocation.MyCommand) -galleryName <galleryName> -location <location> -galleryResourceGroup <galleryResourceGroup>"
    Write-Host "Example: .\$($MyInvocation.MyCommand) -galleryName 'myGallery' -location 'eastus' -galleryResourceGroup 'myResourceGroup'"
    exit 1
}

# Display progress to the user
Write-Host "----------------------------------------------"
Write-Host "Gallery Name: $galleryName"
Write-Host "Location: $location"
Write-Host "Resource Group: $galleryResourceGroup"
Write-Host "----------------------------------------------"
Write-Host "Creating resource in Azure with the provided details..."

# Execute the Azure command to create the resource
az sig create `
    --gallery-name $galleryName `
    --resource-group $galleryResourceGroup `
    --location $location

# Notify the user that the entire operation has been completed successfully
Write-Host "----------------------------------------------"
Write-Host "Operation completed successfully!"
