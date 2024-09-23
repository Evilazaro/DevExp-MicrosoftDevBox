<#
.SYNOPSIS
    This script creates a VM image template in Azure.

.DESCRIPTION
    This script takes twelve parameters: the output file, subscription ID, resource group name, location, image name, identity name, image file URI, gallery name, offer, image SKU, publisher, and identity resource group name.
    It creates an image definition, retrieves the image gallery ID, retrieves the user-assigned identity ID, creates a deployment group, and invokes an action on the resource.

.PARAMETER outputFile
    The output file path.

.PARAMETER subscriptionId
    The Azure subscription ID.

.PARAMETER resourceGroupName
    The name of the resource group.

.PARAMETER location
    The Azure location.

.PARAMETER imageName
    The name of the image.

.PARAMETER identityName
    The name of the identity.

.PARAMETER imageFileUri
    The URI of the image file.

.PARAMETER galleryName
    The name of the image gallery.

.PARAMETER offer
    The offer for the image.

.PARAMETER imgSku
    The SKU for the image.

.PARAMETER publisher
    The publisher of the image.

.PARAMETER identityResourceGroupName
    The name of the resource group for the identity.

.EXAMPLE
    .\CreateVMImageTemplate.ps1 -outputFile "output.json" -subscriptionId "12345678-1234-1234-1234-123456789012" -resourceGroupName "myResourceGroup" -location "EastUS" -imageName "myImage" -identityName "myIdentity" -imageFileUri "https://example.com/image.json" -galleryName "myGallery" -offer "myOffer" -imgSku "mySku" -publisher "myPublisher" -identityResourceGroupName "myIdentityResourceGroup"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$outputFile,

    [Parameter(Mandatory = $true)]
    [string]$subscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [string]$imageName,

    [Parameter(Mandatory = $true)]
    [string]$identityName,

    [Parameter(Mandatory = $true)]
    [string]$imageFileUri,

    [Parameter(Mandatory = $true)]
    [string]$galleryName,

    [Parameter(Mandatory = $true)]
    [string]$offer,

    [Parameter(Mandatory = $true)]
    [string]$imgSku,

    [Parameter(Mandatory = $true)]
    [string]$publisher,

    [Parameter(Mandatory = $true)]
    [string]$identityResourceGroupName
)

# Function to display usage instructions
function Show-Usage {
    Write-Host "Usage: .\CreateVMImageTemplate.ps1 -outputFile <outputFile> -subscriptionId <subscriptionId> -resourceGroupName <resourceGroupName> -location <location> -imageName <imageName> -identityName <identityName> -imageFileUri <imageFileUri> -galleryName <galleryName> -offer <offer> -imgSku <imgSku> -publisher <publisher> -identityResourceGroupName <identityResourceGroupName>"
    exit 1
}

# Function to create an image definition in the Shared Image Gallery
function Create-ImageDefinition {
    param (
        [string]$resourceGroupName,
        [string]$galleryName,
        [string]$imageName,
        [string]$publisher,
        [string]$offer,
        [string]$imgSku,
        [string]$location
    )

    $imageDefName = $imageName
    $features = "SecurityType=TrustedLaunch IsHibernateSupported=true"

    Write-Host "Creating image definition..."

    try {
        az sig image-definition create `
            --resource-group $resourceGroupName `
            --gallery-name $galleryName `
            --gallery-image-definition $imageDefName `
            --os-type Windows `
            --publisher $publisher `
            --offer $offer `
            --sku $imgSku `
            --os-state generalized `
            --hyper-v-generation V2 `
            --features $features `
            --location $location `
            --tags "division=petv2-Platform" "Environment=Prod" "offer=petv2-DevWorkstation-Service" "Team=Engineering" "solution=ContosoFabricDevWorkstation" "businessUnit=e-Commerce"
        Write-Host "Image definition created successfully."
    } catch {
        Write-Error "Error: Failed to create image definition."
        exit 1
    }
}

# Function to retrieve the ID of the image gallery
function Retrieve-ImageGalleryId {
    param (
        [string]$resourceGroupName,
        [string]$galleryName
    )

    Write-Host "Retrieving the ID of the image gallery..."

    try {
        $imageGalleryId = az sig show `
            --resource-group $resourceGroupName `
            --gallery-name $galleryName `
            --query id `
            --output tsv

        if (-not $imageGalleryId) {
            Write-Error "Error: Failed to retrieve the image gallery ID."
            exit 1
        }

        Write-Host "Image gallery ID retrieved successfully."
        return $imageGalleryId
    } catch {
        Write-Error "Error: Failed to retrieve the image gallery ID."
        exit 1
    }
}

# Function to retrieve the ID of the user-assigned identity
function Retrieve-UserAssignedId {
    param (
        [string]$identityResourceGroupName,
        [string]$identityName
    )

    Write-Host "Retrieving the ID of the user-assigned identity..."

    try {
        $userAssignedId = az identity show `
            --resource-group $identityResourceGroupName `
            --name $identityName `
            --query id `
            --output tsv

        if (-not $userAssignedId) {
            Write-Error "Error: Failed to retrieve the user-assigned identity ID."
            exit 1
        }

        Write-Host "User-assigned identity ID retrieved successfully."
        return $userAssignedId
    } catch {
        Write-Error "Error: Failed to retrieve the user-assigned identity ID."
        exit 1
    }
}

# Function to create a deployment group
function Create-DeploymentGroup {
    param (
        [string]$resourceGroupName,
        [string]$imageFileUri,
        [string]$imageName,
        [string]$imageGalleryId,
        [string]$userAssignedId,
        [string]$location
    )

    Write-Host "Creating a deployment group..."

    try {
        az deployment group create `
            --resource-group $resourceGroupName `
            --template-uri $imageFileUri `
            --parameters imgName=$imageName imageGalleryId=$imageGalleryId userAssignedId=$userAssignedId location=$location
        Write-Host "Deployment group created successfully."
    } catch {
        Write-Error "Error: Failed to create deployment group."
        exit 1
    }
}

# Function to invoke an action on the resource
function Invoke-ActionOnResource {
    param (
        [string]$resourceGroupName,
        [string]$imageName
    )

    Write-Host "Invoking an action on the resource..."

    try {
        $resourceId = az resource show `
            --name $imageName `
            --resource-group $resourceGroupName `
            --resource-type "Microsoft.VirtualMachineImages/imageTemplates" `
            --query id `
            --output tsv

        az resource invoke-action `
            --ids $resourceId `
            --action "Run"
        Write-Host "Action invoked on the resource successfully."
    } catch {
        Write-Error "Error: Failed to invoke action on the resource."
        exit 1
    }
}

# Main script execution
function Create-VMImageTemplate {
    param (
        [string]$outputFile,
        [string]$subscriptionId,
        [string]$resourceGroupName,
        [string]$location,
        [string]$imageName,
        [string]$identityName,
        [string]$imageFileUri,
        [string]$galleryName,
        [string]$offer,
        [string]$imgSku,
        [string]$publisher,
        [string]$identityResourceGroupName
    )

    Create-ImageDefinition -resourceGroupName $resourceGroupName -galleryName $galleryName -imageName $imageName -publisher $publisher -offer $offer -imgSku $imgSku -location $location
    $imageGalleryId = Retrieve-ImageGalleryId -resourceGroupName $resourceGroupName -galleryName $galleryName
    $userAssignedId = Retrieve-UserAssignedId -identityResourceGroupName $identityResourceGroupName -identityName $identityName
    Create-DeploymentGroup -resourceGroupName $resourceGroupName -imageFileUri $imageFileUri -imageName $imageName -imageGalleryId $imageGalleryId -userAssignedId $userAssignedId -location $location
    Invoke-ActionOnResource -resourceGroupName $resourceGroupName -imageName $imageName
    Write-Host "Script executed successfully."
}

# Execute the main function with all script arguments
Create-VMImageTemplate -outputFile $outputFile -subscriptionId $subscriptionId -resourceGroupName $resourceGroupName -location $location -imageName $imageName -identityName $identityName -imageFileUri $imageFileUri -galleryName $galleryName -offer $offer -imgSku $imgSku -publisher $publisher -identityResourceGroupName $identityResourceGroupName