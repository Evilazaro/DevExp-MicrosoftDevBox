#!/bin/bash

# Functions

function login {
    local subscriptionName=$1

    ./identity/login.sh $subscriptionName
}

function createResourceGroup {
    local resourceGroupName=$1
    local location=$2

    az group create \
        --name $resourceGroupName \
        --location $location \
        --tags $tags
}

function createIdentity {
    local identityName=$1
    local resourceGroupName=$2
    local subscriptionId=$3

    ./Identity/registerFeatures.sh
    ./identity/createUserAssignedManagedIdentity.sh $resourceGroupName $subscriptionId $identityName
} 

function deployNetworking
{
    local vnetName=$1
    local subNetName=$2
    local networkConnectionName=$3
    local resourceGroupName=$4
    local subscriptionId=$5

    ./networking/deployVnet.sh $vnetName $subNetName $networkConnectionName $resourceGroupName $subscriptionId
}


subscriptionName=$1

# Declaring Variables

# Resources Organization
subscriptionId=$(az account show --query id --output tsv)
devBoxResourceGroupName='ContosoFabric-eShop-DevBox-rg'
imageGalleryResourceGroupName='ContosoFabric-eShop-ImgGallery-rg'
identityResourceGroupName='ContosoFabric-eShop-Identity-rg'
networkingResourceGroupName='ContosoFabric-eShop-Networking-rg'
location='WestUS3'

# Identity
identityName='contosoIdImgBld'
customRoleName='ContosoImageBuilderRole'

# Dev Box 
imageGalleryName='ContosoFabriceShopImgGallery'
frontEndImageName='ContosoFabric-eShop-FrontEnd'
backEndImageName='ContosoFabric-eShop-BackEnd'

# Networking
vnetName='ContosoFabric-eShop-VNet'
subNetName='ContosoFabric-eShop-SubNet'
networkConnectionName='ContosoFabric-eShop-Network-Connection-DevBox'

# Management
managementResourceGroupName='ContosoFabric-eShop-Management-rg'
tags="division=Contoso-Platform \
    Environment=Prod \
    offer=Contoso-DevWorkstation-Service \
    Team=Engineering \
    division=Contoso-Platform \
    solution=eShop \
    businessUnit=e-Commerce"

# Login to Azure
login $subscriptionName

# Deploying Resources Group
createResourceGroup $devBoxResourceGroupName $location
createResourceGroup $imageGalleryResourceGroupName $location
createResourceGroup $identityResourceGroupName $location
createResourceGroup $networkingResourceGroupName $location
createResourceGroup $managementResourceGroupName $location

# Deploying Identity
createIdentity $identityName $identityResourceGroupName $subscriptionId

# Deploying Networking
deployNetworking $vnetName $subNetName $networkConnectionName $networkingResourceGroupName $subscriptionId

