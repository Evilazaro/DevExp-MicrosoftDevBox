#!/bin/bash

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

function buildImage
{
    local subscriptionId="$1"
    local imageGalleryResourceGroupName="$2"
    local location="$3"
    local identityName="$4"
    local galleryName="$5"
    local identityResourceGroupName="$6"
    local devBoxResourceGroupName="$7"
    local networkConnectionName="$8"
    local buildImage=true

    declare -A image_params

    image_params["BackEnd-Docker-Img"]="VS22-BackEnd-Docker petv2-Fabric ../downloadedTempTemplates/BackEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/computeGallery/backEndEngineerImgTemplateDocker.json Contoso"

    for imageName in "${!image_params[@]}"; do
        IFS=' ' read -r imgSKU offer outputFile imageTemplateFile publisher <<< "${image_params[$imageName]}"
        ./createVMImageTemplate.sh "$outputFile" "$subscriptionId" "$imageGalleryResourceGroupName" "$locationComputeGallery" "$imageName" "$identityName" "$imageTemplateFile" "$galleryName" "$offer" "$imgSKU" "$publisher" "$identityResourceGroupName"
        ./devCenter/createDevCenterDefinition.sh "$subscriptionId" "$locationDevCenter" "$devBoxResourceGroupName" "$devCenterName" "$galleryName" "$imageName" "$networkConnectionName" "$buildImage"
    done
}

buildImage "$subscriptionId" "$imageGalleryResourceGroupName" "$location" "$identityName" "$imageGalleryName" "$identityResourceGroupName" "$devBoxResourceGroupName" "$networkConnectionName"