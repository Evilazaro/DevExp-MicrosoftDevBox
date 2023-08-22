#!/bin/bash

# Variables from user input or predefined
resourceGroup=$1
location=$2
vmName=$3
vnetName=$4
subnetName=$5
galleryName=$6
imageName=$7

# Create Virtual Network
echo "Creating Virtual Network..."
az network vnet create --name $vnetName --resource-group $resourceGroup --location $location --subnet-name $subnetName

# Create a VM with a connection to the created Virtual Network
echo "Creating VM with the specified network connection..."
az vm create --resource-group $resourceGroup --name $vmName --image UbuntuLTS --vnet-name $vnetName --subnet $subnetName

# Stop the VM before generalizing
echo "Stopping VM to prepare for generalization..."
az vm stop --resource-group $resourceGroup --name $vmName

# Generalize the VM
echo "Generalizing the VM..."
az vm generalize --resource-group $resourceGroup --name $vmName

# Capture the VM to create an image
echo "Creating an image from the VM..."
az vm capture --resource-group $resourceGroup --name $vmName --vhd-name-prefix $vmName

# Share the image to the gallery
echo "Sharing the VM image to the gallery..."
az sig image-version create --resource-group $resourceGroup --gallery-name $galleryName --gallery-image-definition $imageName --gallery-image-version 1.0.0 --managed-image "/subscriptions/<your-subscription-id>/resourceGroups/$resourceGroup/providers/Microsoft.Compute/images/$vmName"

echo "Operation completed!"

