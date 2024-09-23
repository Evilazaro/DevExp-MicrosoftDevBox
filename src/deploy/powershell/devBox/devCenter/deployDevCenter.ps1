<#
.SYNOPSIS
    This script deploys a DevCenter in Azure.

.DESCRIPTION
    This script takes nine parameters: devCenterName, networkConnectionName, imageGalleryName, location, identityName, devBoxResourceGroupName, networkResourceGroupName, identityResourceGroupName, and imageGalleryResourceGroupName.
    It validates the input parameters, assigns them to variables, fetches necessary IDs, and creates a deployment group using Azure CLI.

.PARAMETER devCenterName
    The name of the DevCenter.

.PARAMETER networkConnectionName
    The name of the network connection.

.PARAMETER imageGalleryName
    The name of the image gallery.

.PARAMETER location
    The Azure location.

.PARAMETER identityName
    The name of the identity.

.PARAMETER devBoxResourceGroupName
    The name of the resource group for the DevBox.

.PARAMETER networkResourceGroupName
    The name of the resource group for the network.

.PARAMETER identityResourceGroupName
    The name of the resource group for the identity.

.PARAMETER imageGalleryResourceGroupName
    The name of the resource group for the image gallery.

.EXAMPLE
    .\DeployDevCenter.ps1 -devCenterName "myDevCenter" -networkConnectionName "myNetworkConnection" -imageGalleryName "myGallery" -location "EastUS" -identityName "myIdentity" -devBoxResourceGroupName "myResourceGroup" -networkResourceGroupName "myNetworkResourceGroup" -identityResourceGroupName "myIdentityResourceGroup" -imageGalleryResourceGroupName "myImageGalleryResourceGroup"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$devCenterName,

    [Parameter(Mandatory = $true)]
    [string]$networkConnectionName,

    [Parameter(Mandatory = $true)]
    [string]$imageGalleryName,

    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [string]$identityName,

    [Parameter(Mandatory = $true)]
    [string]$devBoxResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$networkResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$identityResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$imageGalleryResourceGroupName
)

# Constants
$branch = "main"
$templateFileUri = "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/devBox/devCentertemplate.json"

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\DeployDevCenter.ps1 -devCenterName <devCenterName> -networkConnectionName <networkConnectionName> -imageGalleryName <imageGalleryName> -location <location> -identityName <identityName> -devBoxResourceGroupName <devBoxResourceGroupName> -networkResourceGroupName <networkResourceGroupName> -identityResourceGroupName <identityResourceGroupName> -imageGalleryResourceGroupName <imageGalleryResourceGroupName>"
    exit 1
}

# Function to validate the number of arguments
function Validate-Arguments {
    param (
        [int]$argumentCount
    )

    if ($argumentCount -ne 9) {
        Write-Error "Error: Incorrect number of arguments."
        Show-Usage
    }
}

# Function to display deployment parameters
function Display-DeploymentParameters {
    param (
        [string]$devCenterName,
        [string]$networkConnectionName,
        [string]$imageGalleryName,
        [string]$location,
        [string]$identityName,
        [string]$devBoxResourceGroupName,
        [string]$networkResourceGroupName,
        [string]$identityResourceGroupName,
        [string]$imageGalleryResourceGroupName
    )

    Write-Host "Starting to deploy Dev Center with the following parameters:"
    Write-Host "Dev Center Name: $devCenterName"
    Write-Host "Network Connection Name: $networkConnectionName"
    Write-Host "Image Gallery Name: $imageGalleryName"
    Write-Host "Location: $location"
    Write-Host "Identity Name: $identityName"
    Write-Host "DevBox Resource Group Name: $devBoxResourceGroupName"
    Write-Host "Network Resource Group Name: $networkResourceGroupName"
    Write-Host "Identity Resource Group Name: $identityResourceGroupName"
    Write-Host "Image Gallery Resource Group Name: $imageGalleryResourceGroupName"
}

# Function to fetch the network connection ID
function Fetch-NetworkConnectionId {
    param (
        [string]$networkResourceGroupName
    )

    Write-Host "Fetching network connection ID..."
    try {
        $networkConnectionId = az devcenter admin network-connection list --resource-group $networkResourceGroupName --query [0].id --output tsv
        if (-not $networkConnectionId) {
            Write-Error "Error: Unable to fetch network connection ID."
            exit 1
        }
        Write-Host "Network connection ID fetched successfully."
        return $networkConnectionId
    } catch {
        Write-Error "Error: Failed to fetch network connection ID."
        exit 1
    }
}

# Function to fetch the compute gallery ID
function Fetch-ComputeGalleryId {
    param (
        [string]$imageGalleryResourceGroupName,
        [string]$imageGalleryName
    )

    Write-Host "Fetching compute gallery ID..."
    try {
        $computeGalleryId = az sig show --resource-group $imageGalleryResourceGroupName --gallery-name $imageGalleryName --query id --output tsv
        if (-not $computeGalleryId) {
            Write-Error "Error: Unable to fetch compute gallery ID."
            exit 1
        }
        Write-Host "Compute gallery ID fetched successfully."
        return $computeGalleryId
    } catch {
        Write-Error "Error: Failed to fetch compute gallery ID."
        exit 1
    }
}

# Function to fetch the user identity ID
function Fetch-UserIdentityId {
    param (
        [string]$identityResourceGroupName,
        [string]$identityName
    )

    Write-Host "Fetching user identity ID..."
    try {
        $userIdentityId = az identity show --resource-group $identityResourceGroupName --name $identityName --query id --output tsv
        if (-not $userIdentityId) {
            Write-Error "Error: Unable to fetch user identity ID."
            exit 1
        }
        Write-Host "User identity ID fetched successfully."
        return $userIdentityId
    } catch {
        Write-Error "Error: Failed to fetch user identity ID."
        exit 1
    }
}

# Function to create the deployment group
function Create-DeploymentGroup {
    param (
        [string]$devCenterName,
        [string]$devBoxResourceGroupName,
        [string]$templateFileUri,
        [string]$networkConnectionId,
        [string]$computeGalleryId,
        [string]$location,
        [string]$networkConnectionName,
        [string]$userIdentityId,
        [string]$imageGalleryName
    )

    Write-Host "Creating deployment group..."
    try {
        az deployment group create `
            --name $devCenterName `
            --resource-group $devBoxResourceGroupName `
            --template-uri $templateFileUri `
            --parameters `
                devCenterName=$devCenterName `
                networkConnectionId=$networkConnectionId `
                computeGalleryId=$computeGalleryId `
                location=$location `
                networkConnectionName=$networkConnectionName `
                userIdentityId=$userIdentityId `
                computeGalleryImageName=$imageGalleryName | Out-Null

        Write-Host "Deployment of Dev Center is complete."
    } catch {
        Write-Error "Error: Failed to create deployment group."
        exit 1
    }
}

# Main script execution
function Deploy-DevCenter {
    param (
        [string]$devCenterName,
        [string]$networkConnectionName,
        [string]$imageGalleryName,
        [string]$location,
        [string]$identityName,
        [string]$devBoxResourceGroupName,
        [string]$networkResourceGroupName,
        [string]$identityResourceGroupName,
        [string]$imageGalleryResourceGroupName
    )

    Validate-Arguments -argumentCount $PSCmdlet.MyInvocation.BoundParameters.Count
    Display-DeploymentParameters -devCenterName $devCenterName -networkConnectionName $networkConnectionName -imageGalleryName $imageGalleryName -location $location -identityName $identityName -devBoxResourceGroupName $devBoxResourceGroupName -networkResourceGroupName $networkResourceGroupName -identityResourceGroupName $identityResourceGroupName -imageGalleryResourceGroupName $imageGalleryResourceGroupName

    $networkConnectionId = Fetch-NetworkConnectionId -networkResourceGroupName $networkResourceGroupName
    $computeGalleryId = Fetch-ComputeGalleryId -imageGalleryResourceGroupName $imageGalleryResourceGroupName -imageGalleryName $imageGalleryName
    $userIdentityId = Fetch-UserIdentityId -identityResourceGroupName $identityResourceGroupName -identityName $identityName

    Create-DeploymentGroup -devCenterName $devCenterName -devBoxResourceGroupName $devBoxResourceGroupName -templateFileUri $templateFileUri -networkConnectionId $networkConnectionId -computeGalleryId $computeGalleryId -location $location -networkConnectionName $networkConnectionName -userIdentityId $userIdentityId -imageGalleryName $imageGalleryName
}

# Execute the main function with all script arguments
Deploy-DevCenter -devCenterName $devCenterName -networkConnectionName $networkConnectionName -imageGalleryName $imageGalleryName -location $location -identityName $identityName -devBoxResourceGroupName $devBoxResourceGroupName -networkResourceGroupName $networkResourceGroupName -identityResourceGroupName $identityResourceGroupName -imageGalleryResourceGroupName $imageGalleryResourceGroupName