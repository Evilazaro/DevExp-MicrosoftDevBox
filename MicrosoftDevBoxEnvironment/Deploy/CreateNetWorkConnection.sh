#!/bin/bash

# This script creates a network connection for Azure Development Center using the Azure CLI.
# The connection enables Azure AD domain-join capabilities for VMs in a specified VNet and subnet.

# Check for necessary parameters. If they're missing, inform the user and exit.
if [ "$#" -ne 5 ]; then
    echo "Error: Incorrect number of parameters supplied."
    echo "Usage: $0 <location> <resourceGroupName> <vnetName> <subnetName> <subscriptionId>"
    exit 1
fi

# Collect the necessary parameters from the user input.
location=$1
resourceGroupName=$2
vnetName=$3
subnetName=$4
subscriptionId=$5

# Echo out the provided parameters for clarity. This provides a clearer view of the user's input.
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
echo "Starting the creation process of a network connection for Azure Development Center..."

# Use the Azure CLI to create the network connection. Details like domain join type, resource group, etc., are specified.
az devcenter admin network-connection create \
    --location $location \
    --domain-join-type "AzureADJoin" \
    --networking-resource-group-name $resourceGroupName \
    --subnet-id "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$subnetName" \
    --name "ContostoAzureDevBox-Vnet-Connection" \
    --resource-group $resourceGroupName 

# If the Azure CLI command executed successfully, notify the user. Otherwise, error messages from the `az` command will be displayed.
if [ $? -eq 0 ]; then
    echo "Network connection for Azure Development Center created successfully!"
else
    echo "Failed to create the network connection. Please check the parameters and your Azure credentials."
fi
