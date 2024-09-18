#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
# Treat unset variables as an error
set -o nounset
# Prevent errors in a pipeline from being masked
set -o pipefail

# Function to validate input parameters
validateInput() {
    if [ "$#" -ne 5 ]; then
        echo "Usage: $0 <location> <networkResourceGroupName> <vnetName> <subNetName> <networkConnectionName>"
        exit 1
    fi
}

# Function to retrieve the Subnet ID
getSubnetId() {
    local networkResourceGroupName="$1"
    local vnetName="$2"
    local subNetName="$3"

    echo "Retrieving Subnet ID for $subNetName in VNet $vnetName..."

    local subnetId
    subnetId=$(az network vnet subnet show \
        --resource-group "$networkResourceGroupName" \
        --vnet-name "$vnetName" \
        --name "$subNetName" \
        --query id \
        --output tsv)

    if [ -z "$subnetId" ]; then
        echo "Error: Unable to retrieve the Subnet ID for $subNetName in VNet $vnetName."
        exit 1
    fi

    echo "Subnet ID for $subNetName retrieved successfully: $subnetId"
    echo "$subnetId"
}

# Function to deploy the network connection
deployNetworkConnection() {
    local location="$1"
    local subnetId="$2"
    local networkConnectionName="$3"
    local networkResourceGroupName="$4"

    echo "Deploying Network Connection $networkConnectionName in Resource Group $networkResourceGroupName..."

    if az devcenter admin network-connection create \
        --location "$location" \
        --domain-join-type "AzureADJoin" \
        --subnet-id "$subnetId" \
        --name "$networkConnectionName" \
        --resource-group "$networkResourceGroupName"; then
        echo "Network Connection $networkConnectionName deployed successfully."
    else
        echo "Error: Failed to deploy Network Connection $networkConnectionName."
        exit 1
    fi
}

# Main script execution
createNetWorkConnection() {
    validateInput "$@"

    local location="$1"
    local networkResourceGroupName="$2"
    local vnetName="$3"
    local subNetName="$4"
    local networkConnectionName="$5"

    echo "Initiating the deployment in Resource Group: $networkResourceGroupName, Location: $location."

    local subnetId
    subnetId=$(getSubnetId "$networkResourceGroupName" "$vnetName" "$subNetName")

    deployNetworkConnection "$location" "$subnetId" "$networkConnectionName" "$networkResourceGroupName"
}

# Execute the main function with all script arguments
createNetWorkConnection "$@"