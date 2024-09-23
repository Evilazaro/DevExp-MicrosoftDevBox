<#
.SYNOPSIS
    This script creates a Shared Image Gallery in Azure.

.DESCRIPTION
    This script takes three parameters: the image gallery name, the location, and the resource group name.
    It validates the input parameters, initializes the creation process, and creates the Shared Image Gallery using Azure CLI.

.PARAMETER imageGalleryName
    The name of the Shared Image Gallery to be created.

.PARAMETER location
    The Azure location where the Shared Image Gallery will be created.

.PARAMETER imageGalleryResourceGroupName
    The name of the resource group where the Shared Image Gallery will be created.

.EXAMPLE
    .\DeployComputeGallery.ps1 -imageGalleryName "myGallery" -location "EastUS" -imageGalleryResourceGroupName "myResourceGroup"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$imageGalleryName,

    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [string]$imageGalleryResourceGroupName
)

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\DeployComputeGallery.ps1 -imageGalleryName <imageGalleryName> -location <location> -imageGalleryResourceGroupName <imageGalleryResourceGroupName>"
    exit 1
}

# Function to validate the number of arguments
function Validate-Args {
    param (
        [int]$argumentCount
    )

    if ($argumentCount -ne 3) {
        Write-Error "Error: Invalid number of arguments."
        Show-Usage
    }
}

# Function to inform the user about the initialization process
function Inform-UserAboutInitialization {
    param (
        [string]$imageGalleryName,
        [string]$location,
        [string]$imageGalleryResourceGroupName
    )

    Write-Host "Initializing the creation of a Shared Image Gallery named '$imageGalleryName' in resource group '$imageGalleryResourceGroupName' located in '$location'."
}

# Function to confirm the creation of the Shared Image Gallery
function Confirm-Creation {
    param (
        [string]$imageGalleryName,
        [string]$location,
        [string]$imageGalleryResourceGroupName
    )

    Write-Host "Shared Image Gallery '$imageGalleryName' successfully created in resource group '$imageGalleryResourceGroupName' located in '$location'."
}

# Main function to orchestrate the script execution
function Deploy-ComputeGallery {
    param (
        [string]$imageGalleryName,
        [string]$location,
        [string]$imageGalleryResourceGroupName
    )

    Validate-Args -argumentCount $PSCmdlet.MyInvocation.BoundParameters.Count
    Inform-UserAboutInitialization -imageGalleryName $imageGalleryName -location $location -imageGalleryResourceGroupName $imageGalleryResourceGroupName

    Write-Host "Executing Azure CLI command to create the Shared Image Gallery..."
    try {
        az sig create `
            --gallery-name $imageGalleryName `
            --resource-group $imageGalleryResourceGroupName `
            --location $location `
            --tags "division=petv2-Platform" `
                   "Environment=Prod" `
                   "offer=petv2-DevWorkstation-Service" `
                   "Team=Engineering" `
                   "solution=ContosoFabricDevWorkstation" `
                   "businessUnit=e-Commerce" | Out-Null

        Write-Host "Azure CLI command executed successfully."
    } catch {
        Write-Error "Error: Azure CLI command failed."
        exit 1
    }

    Confirm-Creation -imageGalleryName $imageGalleryName -location $location -imageGalleryResourceGroupName $imageGalleryResourceGroupName
}

# Execute the main function with all script arguments
Deploy-ComputeGallery -imageGalleryName $imageGalleryName -location $location -imageGalleryResourceGroupName $imageGalleryResourceGroupName