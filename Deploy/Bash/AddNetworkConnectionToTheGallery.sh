#!/bin/bash

# Ensure the script stops if any command fails
set -e

# Check if the required number of arguments are provided
if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <resourceGroup> <location> <vmName> <vnetName> <subnetName> <galleryName> <imageName>"
    exit 1
fi

# Variables from user input
resourceGroup="$1"
location="$2"
vmName="$3"
vnetName="$4"
subnetName="$5"
galleryName="$6"
imageName="$7"

# Echo the received inputs
echo "Starting operation with the following inputs:"
echo "Resource Group: $resourceGroup"
echo "Location: $location"
echo "VM Name: $vmName"
echo "VNET Name: $vnetName"
echo "Subnet Name: $subnetName"
echo "Gallery Name: $galleryName"
echo "Image Name: $imageName"
echo "----------------------------------------"

# Create Virtual Network
echo "Creating Virtual Network named $vnetName..."
az network vnet create --name "$vnetName" --resource-group "$resourceGroup" --location "$location" --subnet-name "$subnetName"

# Create a VM with a connection to the created Virtual Network
echo "Creating VM named $vmName with connection to $vnetName..."
az vm create --resource-group "$resourceGroup" --name "$vmName" --image UbuntuLTS --vnet-name "$vnetName" --subnet "$subnetName"

# Stop the VM before generalizing
echo "Stopping $vmName to prepare for generalization..."
az vm stop --resource-group "$resourceGroup" --name "$vmName"

# Generalize the VM
echo "Generalizing the VM named $vmName..."
az vm generalize --resource-group "$resourceGroup" --name "$vmName"

# Capture the VM to create an image
echo "Creating an image from the VM named $vmName..."
az vm capture --resource-group "$resourceGroup" --name "$vmName" --vhd-name-prefix "$vmName"

# Share the image to the gallery
echo "Sharing the VM image of $vmName to the gallery named $galleryName..."
az sig image-version create --resource-group "$resourceGroup" --gallery-name "$galleryName" --gallery-image-definition "$imageName" --gallery-image-version 1.0.0 --managed-image "/subscriptions/<your-subscription-id>/resourceGroups/$resourceGroup/providers/Microsoft.Compute/images/$vmName"

echo "Operation completed!"
