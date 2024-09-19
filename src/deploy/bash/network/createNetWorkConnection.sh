#!/bin/bash

# Ensure all required parameters are provided
validateInput() {
    if [ "$#" -ne 5 ]; then
        echo "Usage: $0 <location> <networkResourceGroupName> <vnetName> <subNetName> <networkConnectionName>"
        exit 1
    fi
}

# Retrieve the subnet ID
getSubnetId() {
    local networkResourceGroupName="$1"
    local vnetName="$2"
    local subNetName="$3"

    echo "Retrieving Subnet ID for $subNetName..."
    subnetId=$(az network vnet subnet show \
        --resource-group "$networkResourceGroupName" \
        --vnet-name "$vnetName" \
        --name "$subNetName" \
        --query id \
        --output tsv)

    if [ -z "$subnetId" ]; then
        echo "Error: Unable to retrieve the Subnet ID for $subNetName in $vnetName."
        exit 1
    fi

    echo "Subnet ID for $subNetName retrieved successfully."
    echo "$subnetId"
}
# Deploy the network connection
deployNetworkConnection() {
    local location="$1"
    local subnetId="$2"
    local networkConnectionName="$3"
    local networkResourceGroupName="$4"

    echo "Deploying Network Connection..."
    az devcenter admin network-connection create \
        --location "$location" \
        --domain-join-type "AzureADJoin" \
        --subnet-id "$subnetId" \
        --name "$networkConnectionName" \
        --resource-group "$networkResourceGroupName"

    # Check the status of the last command
    if [ $? -eq 0 ]; then
        echo "Deployment initiated successfully."
    else
        echo "Error: Deployment failed."
        exit 1
    fi
}

# Main function to create network connection
createNetworkConnection() {
    # Validate input parameters
    validateInput "$@"

    local location="$1"
    local networkResourceGroupName="$2"
    local vnetName="$3"
    local subNetName="$4"
    local networkConnectionName="$5"

    echo "Initiating the deployment in the resource group: $networkResourceGroupName, location: $location."

    # Retrieve the subnet ID
    local subnetId
    subnetId=getSubnetId "$networkResourceGroupName" "$vnetName" "$subNetName"

    # Deploy the network connection
    deployNetworkConnection "$location" "$subnetId" "$networkConnectionName" "$networkResourceGroupName"

    echo "Deployment completed successfully."
}

# Execute the main function with all script arguments
createNetworkConnection "$@"