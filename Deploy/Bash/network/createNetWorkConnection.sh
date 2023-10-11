#!/bin/bash

# Ensure all required parameters are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <location> <networkResourceGroupName> <vnetName> <subNetName> <networkConnectionName>"
    exit 1
fi

# Assign positional parameters to meaningful variable names
location="$1"
networkResourceGroupName="$2"
vnetName="$3"
subNetName="$4"
networkConnectionName="$5"

# Echo starting the operation
echo "Initiating the deployment in the resource group: $networkResourceGroupName, location: $location."

# Retrieve the subnet ID
echo "Retrieving Subnet ID for $subNetName..."
subnetId=$(az network vnet subnet show \
    --resource-group "$networkResourceGroupName" \
    --vnet-name "$vnetName" \
    --name "$subNetName" \
    --query id \
    --output tsv)

# Check the successful retrieval of subnetId
if [ -z "$subnetId" ]; then
    echo "Error: Unable to retrieve the Subnet ID for $subNetName in $vnetName."
    exit 1
fi
echo "Subnet ID for $subNetName retrieved successfully."


echo "Deploying Network Connection"
az devcenter admin network-connection create \
    --location "$location" \
    --domain-join-type "AzureADJoin" \
    --networking-resource-group-name "$networkResourceGroupName" \
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

# Exit normally
exit 0
