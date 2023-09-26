#!/bin/bash

# Assign command-line arguments to variables
outputFile="$1"
subscriptionID="$2"
resourceGroupName="$3"
location="$4"
imageName="$5"
identityName="$6"
imageFileUri="$7"
galleryName="$8"
offer="$9"
imgSKU="${10}"
publisher="${11}"
identityResourceGroupName="${12}"

imageDefName="${imageName}-def"
features="SecurityType=TrustedLaunch IsHibernateSupported=true"

az sig image-definition create \
    --resource-group ${resourceGroupName} \
    --gallery-name ${galleryName} \
    --gallery-image-definition ${imageDefName} \
    --os-type Windows \
    --publisher ${publisher} \
    --offer ${offer} \
    --sku ${imgSKU} \
    --os-state generalized \
    --hyper-v-generation V2 \
    --features "${features}" \
    --location ${location} \
    --tags  "division=Contoso-Platform" \
            "Environment=Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "division=Contoso-Platform" \
            "solution=eShop" \
            "businessUnit=e-Commerce"


imagegalleryId=$(az sig show --resource-group ${resourceGroupName} \
                --gallery-name ${galleryName} --query id --output tsv)

userAssignedId=$(az identity show --resource-group ${identityResourceGroupName} \
                --name ${identityName} --query id --output tsv)

az deployment group create \
    --resource-group ${resourceGroupName} \
    --template-file ${imageFileUri}  \
    --parameters imgName=${imageName} \
                 imageGalleryId=${imageGalleryId} \
                 userAssignedId=${userAssignedId} \
                 location=${location} \
    --tags "division=Contoso-Platform" \
            "Environment=Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "division=Contoso-Platform" \
            "solution=eShop" \
            "businessUnit=e-Commerce"

az resource invoke-action \
    --ids $(az resource show --name ${imageName} --resource-group ${resourceGroupName} --resource-type "Microsoft.VirtualMachineImages/imageTemplates" --query id --output tsv) \
    --action "Run" \
    --request-body '{}' \
    --query properties.outputs
    

