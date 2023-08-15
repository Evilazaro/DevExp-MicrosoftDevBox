#!/bin/bash

# This script creates a network connection for Azure Development Center using the Azure CLI.
# The connection is used to enable Azure AD domain-join capabilities for VMs in a specified VNet and subnet.

# Collect the necessary parameters from the user input.
location=$1
resourceGroupName=$2
vnetName=$3
subnetName=$4
subscriptionId=$5

# Echo out the provided parameters for clarity, giving a clearer view of the user's input.
echo "-----------------------------------------"
echo "Parameters for Network Connection:"
echo "-----------------------------------------"
echo "Location: $location"
echo "Resource Group Name: $resourceGroupName"
echo "VNet Name: $vnetName"
echo "Subnet Name: $subnetName"
echo "Subscription ID: $subscriptionId"
echo "-----------------------------------------"

# Inform the user that the network connection creation process is starting.
echo "Creating a network connection for Azure Development Center..."

# Use the Azure CLI to create the network connection, specifying necessary details like domain join type, resource group, and more.
az devcenter admin network-connection create \
    --location $location \
    --domain-join-type "AzureADJoin" \
    --networking-resource-group-name $resourceGroupName \
    --subnet-id "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$subnetName" \
    --name "ContostoAzureDevBox-Vnet-Connection" \
    --resource-group $resourceGroupName 

# Once the Azure CLI command has executed successfully, notify the user of the successful creation.
echo "Network connection for Azure Development Center created successfully!"
