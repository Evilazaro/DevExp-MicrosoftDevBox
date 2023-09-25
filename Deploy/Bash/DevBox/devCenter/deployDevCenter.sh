#!/bin/bash

devCenterName="$1"
networkConnectionName="$2"
computeGalleryName="$3"
location="$4"
identityName="$5"
devBoxResourceGroupName="$6"
networkResourceGroupName="$7"
identityResourceGroupName="$8"

branch="Dev"
templateFileUri="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/Deploy/ARMTemplates/devBox/devCentertemplate.json"
networkConnectionId=$(az devcenter admin network-connection list --resource-group $networkResourceGroupName --query [0].id --output tsv)
computeGalleryId=$(az sig show --resource-group $devBoxResourceGroupName --gallery-name $computeGalleryName --query id --output tsv)
userIdentityId=$(az identity show --resource-group $identityResourceGroupName --name $identityName --query id --output tsv)

az deployment group create \
    --name "devCenterDeployment" \
    --resource-group "$devBoxResourceGroupName" \
    --template-uri $templateFileUri \
    --parameters \
        devCenterName="$devCenterName" \
        networkConnectionId="$networkConnectionId" \
        computeGalleryId="$computeGalleryId" \
        location="$location" \
        networkConnetionName="$networkConnetionName" \
        userIdenityId="$userIdenityId" \
    --tags  "division=Contoso-Platform" \
            "Environment=Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "division=Contoso-Platform" \
            "solution=eShop" \
            "businessUnit=e-Commerce"