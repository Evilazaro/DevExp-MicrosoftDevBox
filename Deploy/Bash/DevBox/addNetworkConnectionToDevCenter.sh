#!/usr/bin/env bash

# Check if the correct number of arguments is passed; if not, display a usage message and exit
if [ "$#" -ne 5 ]; then
  echo "Usage: $0 devCenterName imageResourceGroupName location vnetName subnetName"
  exit 1
fi

# Check if the 'az' CLI tool is installed; if not, display an error message and exit
if ! command -v az &> /dev/null; then
  echo "Error: 'az' CLI tool is not installed."
  exit 1
fi

# Assign arguments to variables with meaningful names and echo the input parameters
devCenterName="$1"
imageResourceGroupName="$2"
location="$3"
vnetName="$4"
subnetName="$5"

echo "Dev Center Name: $devCenterName"
echo "Image Resource Group Name: $imageResourceGroupName"
echo "Location: $location"
echo "VNet Name: $vnetName"
echo "Subnet Name: $subnetName"

# Get the subnet ID using the 'az' CLI tool and store it in the 'subnetId' variable
echo "Fetching subnet ID..."
subnetId=$(az network vnet subnet show --resource-group "$imageResourceGroupName" --vnet-name "$vnetName" --name "$subnetName" --query id --output tsv)
if [ -z "$subnetId" ]; then
  echo "Error: Failed to fetch subnet ID."
  exit 1
fi
echo "Subnet ID: $subnetId"

# Create a network connection using the 'az' CLI tool with the gathered details
echo "Creating network connection..."
az devcenter admin network-connection create --location "$location" \
    --domain-join-type "AzureADJoin" \
    --subnet-id "$subnetId" \
    --name "devcenter-network-connection" \
    --resource-group "$imageResourceGroupName"

# Check if the command was successful and inform the user accordingly
if [ "$?" -eq 0 ]; then
  echo "Network connection created successfully."
else
  echo "Error: Failed to create network connection."
  exit 1
fi
