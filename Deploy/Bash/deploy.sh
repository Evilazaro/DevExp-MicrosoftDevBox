#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# This script automates various Azure tasks like resource group creation, image creation, and deployment.

display_header() {
    echo -e "\n========================\n$1\n========================"
}

build_image() {
    local outputFile="$1" subscriptionID="$2" resourceGroupName="$3" location="$4" imageName="$5"
    local identityName="$6" imageTemplateFile="$7" galleryName="$8" offer="$9" imgSKU="${10}"
    local publisher="${11}"

    display_header "Creating Image: $imageName"
    cat <<EOL
Image Template URL: $imageTemplateFile
Output File: $outputFile
Subscription ID: $subscriptionID
Resource Group: $resourceGroupName
Location: $location
Image Name: $imageName
Identity Name: $identityName
Gallery Name: $galleryName
Offer: $offer
SKU: $imgSKU
Publisher: $publisher
EOL

    VMImages/buildVMImage.sh "$outputFile" "$subscriptionID" "$resourceGroupName" "$location" \
                            "$imageName" "$identityName" "$imageTemplateFile" "$galleryName" \
                            "$offer" "$imgSKU" "$publisher" || { echo "Image building failed"; exit 1; }
}

# Logging into Azure
display_header "Logging into Azure"
./Identity/login.sh "$1"

# Setting up static variables
display_header "Setting Up Variables"
resourceGroupName='ContosoFabric-eShop-DevBox-rg'
location='WestUS3'
identityName='contosoIdImgBld'
subscriptionID=$(az account show --query id --output tsv)
devCenterName="ContosoFabric-DevCenter"
galleryName="ContosoFabriceShopImgGallery"

# Creating Azure resources
echo "Creating resource group and managed identity..."
az group create -n "$resourceGroupName" -l "$location" --tags "division=Contoso-Platform" "Environment=Prod" "offer=Contoso-DevWorkstation-Service" "Team=Engineering"
az identity create --resource-group "$resourceGroupName" -n "$identityName"
identityId=$(az identity show --resource-group "$resourceGroupName" -n "$identityName" --query principalId --output tsv)

# Displaying configuration summary
display_header "Configuration Summary"
echo -e "Image Resource Group: $resourceGroupName\nLocation: $location\nSubscription ID: $subscriptionID\nIdentity Name: $identityName\nIdentity ID: $identityId"

# Running additional setup scripts
echo "Registering necessary features and creating user-assigned managed identity..."
./Identity/registerFeatures.sh
./Identity/createUserAssignedManagedIdentity.sh "$resourceGroupName" "$subscriptionID" "$identityId"

echo "Deploying Compute Gallery ${galleryName}..."
./ComputeGallery/deployComputeGallery.sh "$galleryName" "$location" "$resourceGroupName"

# Deploying DevBox
display_header "Deploying Microsoft DevBox"
./DevBox/deployDevBox.sh "$subscriptionID" "$location" "$resourceGroupName" "$identityName" "$galleryName" "$devCenterName"

display_header "Building Virtual Machine Images"

declare -A image_params
#image_params["FrontEnd-Img"]="VSCode-FrontEnd Contoso-Fabric ./DownloadedTempTemplates/FrontEnd-Img-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-FrontEnd-Template.json Contoso"
image_params["FrontEnd-Docker-Img"]="VSCode-FrontEnd-Docker Contoso-Fabric ./DownloadedTempTemplates/FrontEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-FrontEnd-Docker-Template.json Contoso"
#image_params["BackEnd-Img"]="VS22-BackEnd Contoso-Fabric ./DownloadedTempTemplates/BackEnd-Img-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-BackEnd-Template.json Contoso"
#image_params["BackEnd-Docker-Img"]="VS22-BackEnd-Docker Contoso-Fabric ./DownloadedTempTemplates/BackEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-BackEnd-Docker-Template.json Contoso"
# ... add other entries in the same format

for imageName in "${!image_params[@]}"; do
    IFS=' ' read -r imgSKU offer outputFile imageTemplateFile publisher <<< "${image_params[$imageName]}"
    build_image "$outputFile" "$subscriptionID" "$resourceGroupName" "$location" "$imageName" "$identityName" "$imageTemplateFile" "$galleryName" "$offer" "$imgSKU" "$publisher"
    ./DevBox/createDevBoxDefinition.sh "$subscriptionID" "$location" "$resourceGroupName" "$devCenterName" "$galleryName" "$imageName"
done
