#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

# Variables
branch="main"
location="WestUS3"
locationComputeGallery="WestUS3"
locationDevCenter="WestUS3"

# Azure Resource Group Names
devBoxResourceGroupName="petv2DevBox-rg"
imageGalleryResourceGroupName="petv2ImageGallery-rg"
identityResourceGroupName="petv2IdentityDevBox-rg"
networkResourceGroupName="petv2NetworkConnectivity-rg"
managementResourceGroupName="petv2DevBoxManagement-rg"

# Identity Variables
identityName="petv2DevBoxImgBldId"
customRoleName="petv2BuilderRole"

# Image and DevCenter Names
imageGalleryName="petv2ImageGallery"
frontEndImageName="frontEndVm"
backEndImageName="backEndVm"
devCenterName="petv2DevCenter"

# Network Variables
vnetName="petv2Vnet"
subNetName="petv2SubNet"
networkConnectionName="devBoxNetworkConnection"

# Function to build images and create DevCenter definitions
buildImage() {
    local subscriptionId="$1"
    local imageGalleryResourceGroupName="$2"
    local location="$3"
    local identityName="$4"
    local galleryName="$5"
    local identityResourceGroupName="$6"
    local devBoxResourceGroupName="$7"
    local networkConnectionName="$8"
    local buildImage=true

    declare -A imageParams
    imageParams["BackEnd-Docker-Img"]="VS22-BackEnd-Docker petv2-Fabric ../downloadedTempTemplates/BackEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/computeGallery/backEndEngineerImgTemplateDocker.json Contoso"

    for imageName in "${!imageParams[@]}"; do
        IFS=' ' read -r imgSku offer outputFile imageTemplateFile publisher <<< "${imageParams[$imageName]}"
        
        echo "Creating VM Image Template for $imageName..."
        ./createVMImageTemplate.sh "$outputFile" "$subscriptionId" "$imageGalleryResourceGroupName" "$locationComputeGallery" "$imageName" "$identityName" "$imageTemplateFile" "$galleryName" "$offer" "$imgSku" "$publisher" "$identityResourceGroupName"
        
        echo "Creating DevCenter Definition for $imageName..."
        ./devCenter/createDevCenterDefinition.sh "$subscriptionId" "$locationDevCenter" "$devBoxResourceGroupName" "$devCenterName" "$galleryName" "$imageName" "$networkConnectionName" "$buildImage"
    done
}

# Main script execution
main() {
    if [[ $# -ne 8 ]]; then
        echo "Usage: $0 <subscriptionId> <imageGalleryResourceGroupName> <location> <identityName> <galleryName> <identityResourceGroupName> <devBoxResourceGroupName> <networkConnectionName>"
        exit 1
    fi

    buildImage "$@"
}

main "$@"