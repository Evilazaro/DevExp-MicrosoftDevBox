#!/bin/bash

# This script automates various Azure tasks like resource group creation, image creation, and deployment.

# Displays a header for better script output readability.
display_header() {
    echo
    echo "========================"
    echo "$1"
    echo "========================"
}

# Builds a virtual machine image in Azure.
build_image() {
    local outputFile="$1"
    local subscriptionID="$2"
    local galleryResourceGroup="$3"
    local location="$4"
    local imageName="$5"
    local identityName="$6"
    local imageTemplateFile="$7"
    local galleryName="$8"
    local offer="$9"
    local imgSKU="${10}"
    local publisher="${11}"

    display_header "Creating Image: $imageName"
    
    # Displaying the provided parameters for transparency.
    cat <<EOL
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
EOL

    VMImages/buildVMImage.sh "$outputFile" "$subscriptionID" "$galleryResourceGroup" "$location" "$imageName" "$identityName" "$imageTemplateFile" "$galleryName" "$offer" "$imgSKU" "$publisher"
}

# Logging into Azure.
display_header "Logging into Azure"
./Identity/login.sh "$1"

# Setting up static variables.
display_header "Setting Up Variables"
galleryResourceGroup='Contoso-DevBox2-rg'
location='WestUS3'
identityName='contosoIdentityIBuilderUserDevBox'
subscriptionID=$(az account show --query id --output tsv)

# Creating Azure resources.
echo "Creating resource group: $galleryResourceGroup in location: $location..."
az group create -n "$galleryResourceGroup" -l "$location" \
                 --tags  "division=Contoso-Platform" \
                        "Environment=DevWorkstationService-Prod" \
                        "offer=Contoso-DevWorkstation-Service" \
                        "Team=eShopOnContainers" 

echo "Creating managed identity: $identityName..."
az identity create --resource-group "$galleryResourceGroup" -n "$identityName"
identityId=$(az identity show --resource-group "$galleryResourceGroup" -n "$identityName" --query principalId --output tsv)

# Displaying configuration summary.
display_header "Configuration Summary"
cat <<EOL
Image Resource Group: $galleryResourceGroup
Location: $location
Subscription ID: $subscriptionID
Identity Name: $identityName
Identity ID: $identityId
EOL

# Running additional setup scripts.
echo "Registering necessary features..."
./Identity/registerFeatures.sh

echo "Creating user-assigned managed identity..."
./Identity/createUserAssignedManagedIdentity.sh "$galleryResourceGroup" "$subscriptionID" "$identityId"

echo "Starting the process..."
echo "Deploying Compute Gallery ${galleryName}..."
galleryName="ContosoImageGallery"
./ComputeGallery/deployComputeGallery.sh "$galleryName" "$location" "$galleryResourceGroup"

# Building virtual machine images.
imagesku='Win11-Engineers-FrontEnd'
publisher='Contoso'
offer='Contoso-Fabric'
build_image './DownloadedTempTemplates/Win11-Ent-Base-Image-FrontEnd-Template-Output.json' "$subscriptionID" "$galleryResourceGroup" "$location" 'Win11EntBaseImageFrontEndEngineers' 'contosoIdentityIBuilderUserDevBox' 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-FrontEnd-Template.json' "$galleryName" "$offer" "$imagesku" "$publisher" 

imagesku='VS22-Engineers-BackEnd'
#build_image './DownloadedTempTemplates/Win11-Ent-Base-Image-BackEnd-Template-Output.json' "$subscriptionID" "$galleryResourceGroup" "$location" 'Win11EntBaseImageBackEndEngineers' 'contosoIdentityIBuilderUserDevBox' 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-BackEnd-Template.json' "$galleryName" "$offer" "$imagesku" "$publisher"

imagesku='VS22-Engineers-BackEnd-Docker'
#build_image './DownloadedTempTemplates/Win11-Ent-Base-Image-BackEnd-Docker-Template-Output.json' "$subscriptionID" "$galleryResourceGroup" "$location" 'Win11EntBaseImageBackEndDockerEngineers' 'contosoIdentityIBuilderUserDevBox' 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-BackEnd-Docker-Template.json' "$galleryName" "$offer" "$imagesku" "$publisher"

# Deploying DevBox.
display_header "Deploying Microsoft DevBox"
# Uncomment the line below once you have the correct parameters for deployment.
./DevBox/deployDevBox.sh "$subscriptionID" "$location" "$galleryResourceGroup" "$identityName"