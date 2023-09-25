#!/bin/bash

branch="Dev"
location="$1"
networkingResourceGroupName="$2"
vnetName="$3"
subNetName="$4"
networkConnectionName="$5"

templateFilePath="$6"

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