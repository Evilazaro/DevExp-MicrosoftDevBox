# This script automates various Azure tasks like resource group creation, image creation, and deployment.

# Displays a header for better script output readability.
function Display-Header {
    param (
        [string]$headerText
    )
    
    Write-Output ""
    Write-Output "========================"
    Write-Output $headerText
    Write-Output "========================"
}

# Builds a virtual machine image in Azure.
function Build-Image {
    param (
        $outputFile,
        $subscriptionID,
        $galleryResourceGroup,
        $location,
        $imageName,
        $identityName,
        $imageTemplateFile,
        $galleryName,
        $offer,
        $imgSKU,
        $publisher
    )
    
    Display-Header "Creating Image: $imageName"
    
    # Displaying the provided parameters for transparency.
    Write-Output @"
Image Template URL: $imageTemplateFile
Output File: $outputFile
Subscription ID: $subscriptionID
Gallery Resource Group: $galleryResourceGroup
Location: $location
Image Name: $imageName
Identity Name: $identityName
Gallery Name: $galleryName
Offer: $offer
SKU: $imgSKU
Publisher: $publisher
"@
    
    .\VMImages\buildVMImage.ps1 $outputFile $subscriptionID $galleryResourceGroup $location $imageName $identityName $imageTemplateFile $galleryName $offer $imgSKU $publisher
}

# Logging into Azure.
Display-Header "Logging into Azure"
.\Identity\login.ps1 $args[0]

# Setting up static variables.
Display-Header "Setting Up Variables"
$galleryResourceGroup = 'Contoso-Base-Images-Engineers-rg'
$location = 'WestUS3'
$identityName = 'contosoIdImgBld'
$subscriptionID = (az account show --query id --output tsv)

# Creating Azure resources.
Write-Output "Creating resource group: $galleryResourceGroup in location: $location..."
az group create -n $galleryResourceGroup -l $location

Write-Output "Creating managed identity: $identityName..."
az identity create --resource-group $galleryResourceGroup -n $identityName
$identityId = (az identity show --resource-group $galleryResourceGroup -n $identityName --query principalId --output tsv)

# Displaying configuration summary.
Display-Header "Configuration Summary"
Write-Output @"
Image Resource Group: $galleryResourceGroup
Location: $location
Subscription ID: $subscriptionID
Identity Name: $identityName
Identity ID: $identityId
"@

# Running additional setup scripts.
Write-Output "Registering necessary features..."
.\Identity\registerFeatures.ps1

Write-Output "Creating user-assigned managed identity..."
.\Identity\createUserAssignedManagedIdentity.ps1 $galleryResourceGroup $subscriptionID $identityId

Write-Output "Starting the process..."
Write-Output "Deploying Compute Gallery ${galleryName}..."
$galleryName = "ContosoFabriceShopImgGallery"
.\ComputeGallery\deployComputeGallery.ps1 $galleryName $location $galleryResourceGroup

# Building virtual machine images.
$imagesku = 'Win11-Engineers-FrontEnd'
$publisher = 'Contoso'
$offer = 'Contoso-Fabric'

Build-Image './DownloadedTempTemplates/Win11-Ent-Base-Image-FrontEnd-Template-Output.json' $subscriptionID $galleryResourceGroup $location 'Win11EntBaseImageFrontEndEngineers' 'contosoIdImgBld' 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-FrontEnd-Template.json' $galleryName $offer $imagesku $publisher

$imagesku = 'VS22-Engineers-BackEnd'
Build-Image './DownloadedTempTemplates/Win11-Ent-Base-Image-BackEnd-Template-Output.json' $subscriptionID $galleryResourceGroup $location 'Win11EntBaseImageBackEndEngineers' 'contosoIdImgBld' 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-BackEnd-Template.json' $galleryName $offer $imagesku $publisher

Build-Image './DownloadedTempTemplates/Win11-Ent-Base-Image-BackEnd-Docker-Template-Output.json' $subscriptionID $galleryResourceGroup $location 'Win11EntBaseImageBackEndDockerEngineers' 'contosoIdImgBld' 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-BackEnd-Docker-Template.json' $galleryName $offer $imagesku $publisher

# Deploying DevBox.
Display-Header "Deploying Microsoft DevBox"
# Uncomment the line below once you have the correct parameters for deployment.
# .\DevBox\deployDevBox.ps1 $subscriptionID $location 'Win11EntBaseImageFrontEndEngineers' 'Win11EntBaseImageBackEndEngineers' $galleryResourceGroup
