#!/bin/bash

# Assigning input arguments to variables
subscriptionId="$1"
location="$2"
resourceGroupName="$3"
devCenterName="$4"
galleryName="$5"
imageName="$6"

# Construct necessary variables
imageReferenceId="/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/${galleryName}/images/${imageName}-def/"
devBoxDefinitionName="devBox-$imageName"
networkConnectionName="Contoso-Network-Connection-DevBox"
projectName="eShop"
poolName="$imageName-pool"
devBoxName="$imageName-devbox"

 az devcenter admin devbox-definition create --location "$location" \
        --image-reference id="$imageReferenceId" \
        --os-storage-type "ssd_256gb" \
        --sku name="general_i_8c32gb256ssd_v2" \
        --name "$devBoxDefinitionName" \
        --dev-center-name "$devCenterName" \
        --resource-group "$resourceGroupName" \
        --devbox-definition-name "devBox-$imageName" \
        --tags  "division=Contoso-Platform" \
                    "Environment=Prod" \
                    "offer=Contoso-DevWorkstation-Service" \
                    "Team=Engineering" \
                    "solution=eShop" \
                    "businessUnit=e-Commerce"

./DevBox/createDevBoxPools.sh "$location" "$devBoxDefinitionName" "$networkConnectionName" "$poolName" "$projectName" "$resourceGroupName"
./DevBox/createDevBoxforEngineers.sh "$poolName" "$devBoxName" "$devCenterName" "$projectName"

