#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
location="northuscentral"
solutionName="ContosoDx"
devBoxResourceGroupName="ContosoDx-rg"
networkResourceGroupName="ContosoDx-Network-rg"
managementResourceGroupName="ContosoDx-Management-rg"

# Function to deploy management resources
deployManagementResources() {
    echo "Deploying management resources..."
    echo "Management Resource Group: $managementResourceGroupName"
    echo "Location: $location"

    # Deploys Bicep template to Azure
    if az deployment group create --resource-group "$managementResourceGroupName" \
        --template-file "../management/logAnalytics/deploy.bicep" --parameters solutionName="$solutionName"; then
        echo "Management resources deployed successfully."
    else
        echo "Failed to deploy management resources." >&2
        exit 1
    fi
}

deployNetworkResources() {
    echo "Deploying network resources..."
    echo "Network Resource Group: $networkResourceGroupName"
    echo "Location: $location"

    # Deploys Bicep template to Azure
    if az deployment group create --resource-group "$networkResourceGroupName" \
        --template-file "../network/deploy.bicep" --parameters solutionName="$solutionName" managementResourceGroupName="$managementResourceGroupName"; then
        echo "Network resources deployed successfully."
    else
        echo "Failed to deploy network resources." >&2
        exit 1
    fi
}

deployDevCenterResources() {
    echo "Deploying Dev Center resources..."
    echo "Dev Center Resource Group: $devBoxResourceGroupName"
    echo "Location: $location"

    # Deploys Bicep template to Azure
    if az deployment group create --resource-group "$devBoxResourceGroupName" \
        --template-file "../devBox/deploy.bicep" --parameters solutionName="$solutionName" managementResourceGroupName="$managementResourceGroupName"; then
        echo "Dev Center resources deployed successfully."
    else
        echo "Failed to deploy Dev Center resources." >&2
        exit 1
    fi
}

# Main script execution
echo "Starting deployment script..."

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Azure CLI could not be found. Please install it and try again." >&2
    exit 1
fi

# Call the function to deploy management resources
deployManagementResources

# Call the function to deploy network resources
deployNetworkResources

# Call the function to deploy Dev Center resources
deployDevCenterResources

echo "Deployment script completed."