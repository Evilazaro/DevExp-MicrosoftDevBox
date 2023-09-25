#!/bin/bash

branch="Dev"
location="$1"
networkingResourceGroupName="$2"
vnetName="$3"
subNetName="$4"
networkConnectionName="$5"

templateFilePath="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/Deploy/ARMTemplates/networking/networkConnectionTemplate.json"

subnetId=$(az network vnet subnet show \
    --resource-group $networkingResourceGroupName \
    --vnet-name $vnetName \
    --name $subNetName \
    --query id \
    --output tsv)

az devcenter admin network-connection create \
    --location "$location" \
    --domain-join-type "AzureADJoin" \
    --networking-resource-group-name "$networkingResourceGroupName" \
    --subnet-id "$subnetId" \
    --name "$networkConnectionName" \
    --resource-group "$resourceGroupName" \
    --tags  "division=Contoso-Platform" \
            "Environment=Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "division=Contoso-Platform" \
            "solution=eShop" 


az group deployment create \
    --resource-group "$networkingResourceGroupName" \
    --template-uri "$templateFilePath" \
    --parameters \
        name="$networkConnectionName" \
        vnetId="$vnetId" \
        location="$location" \
        subnetName="$subNetName" \
    --no-wait