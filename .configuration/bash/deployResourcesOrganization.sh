#!/bin/bash


devBoxResourceGroupName="$1"
networkResourceGroupName="$2"
location="$3"

# Function to create an Azure resource group
createResourceGroup() {
    local resourceGroupName="$1"

    if [[ -z "$resourceGroupName" || -z "$location" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createResourceGroup <resourceGroupName> <location>"
        return 1
    fi

    echo "Creating Azure Resource Group: $resourceGroupName in $location"

    if az group create --name "$resourceGroupName" --location "$location" \
        --tags \
        "workload=workloadName" \
        "landingZone=DevEx" \
        "resourceType=Resource Group" \
        "ProductTeam=Platform Engineering" \
        "Environment=Production" \
        "Department=IT" \
        "workload=DevBox-as-a-Service"; then
        
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
}

validateInputs() {
    if [[ -z "$devBoxResourceGroupName" || -z "$networkResourceGroupName" || -z "$location" ]]; then
        devBoxResourceGroupName='ContosoDevEx-rg'
        networkResourceGroupName='ContosoDevEx-Network-rg'
        location='northuscentral'
    fi
}

deployResourcesOrganization
