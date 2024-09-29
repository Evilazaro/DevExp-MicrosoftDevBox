#!/bin/bash

location="WestUS3"

solutionName="eShopPetDevBox"
devBoxResourceGroupName="$solutionName-rg"
networkResourceGroupName="$solutionName-Management-rg"
managementResourceGroupName="$solutionName-Network-rg"

# Function to create an Azure resource group
createResourceGroup() {
    local resourceGroupName="$1"

    if [[ -z "$resourceGroupName" || -z "$location" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createResourceGroup <resourceGroupName> <location>"
        return 1
    fi

    echo "Creating Azure Resource Group: $resourceGroupName in $location"

    if az group create --name "$resourceGroupName" --location "$location" --tags "division=eShopPet-Platform" "Environment=Prod" "offer=eShopPet-DevWorkstation-Service" "Team=Engineering" "solution=ContosoFabricDevWorkstation"; then
        echo "Resource group '$resourceGroupName' created successfully."
    else
        echo "Error: Failed to create resource group '$resourceGroupName'."
        return 1
    fi
}

# Function to deploy resources for the organization
deployResourcesOrganization() {

    createResourceGroup "$devBoxResourceGroupName"
    createResourceGroup "$networkResourceGroupName"
    createResourceGroup "$managementResourceGroupName"
}

deployResourcesOrganization
