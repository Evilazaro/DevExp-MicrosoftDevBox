#!/bin/bash

# Assign arguments to meaningful variable names.
resourceGroupName="$1"
location="$2"
vnetName="$3"
subnetName="$4"
tags="$5"

# Declaring Variables
vnetAddressPrefix="10.0.0.0/16"
subnetAddressPrefix="10.0.0.0/24"

# Create the Virtual Network and Subnet using the Azure CLI.
az network vnet create \
    --resource-group "$resourceGroupName" \
    --name "$vnetName" \
    --address-prefix "$vnetAddressPrefix" \
    --subnet-name "$subnetName" \
    --subnet-prefix "$subnetAddressPrefix" \
    --tags  $tags
