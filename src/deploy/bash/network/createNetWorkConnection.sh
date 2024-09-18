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

deployNetworkConnection() {
    local location="$1"
    local subnetId="$2"
    local networkConnectionName="$3"
    local networkResourceGroupName="$4"

    echo "Deploying Network Connection"
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

# Main Execution
validateInput "$@"

location="$1"
networkResourceGroupName="$2"
vnetName="$3"
subNetName="$4"
networkConnectionName="$5"
subnetId=""

echo "Initiating the deployment in the resource group: $networkResourceGroupName, location: $location."

getSubnetId "$networkResourceGroupName" "$vnetName" "$subNetName"
deployNetworkConnection "$location" "$subnetId" "$networkConnectionName" "$networkResourceGroupName"

# Exit normally
exit 0
