#!/bin/bash

# This script automates the creation of an Azure Resource Group, a Virtual Network (VNet) inside that Resource Group, 
# and sets up a network connection for Azure Development Center with domain-join capabilities.

# Check if a subscription ID has been provided. If not, exit the script with an error message.
if [ -z "$1" ]; then
    echo "Error: Subscription ID not provided!"
    echo "Usage: $0 [SUBSCRIPTION_ID]"
    exit 1
fi

# Set the Azure subscription ID from the first argument.
subscriptionId=$1
location=$2
frontEndEngineersImageName=$3
backEndEngineersImageName=$4
imageResourceGroupName=$5

# Define fixed variables for the resource group, location, virtual network, and subnet names.
devBoxResourceGroupName="Contoso-AzureDevBox-rg"
vnetName="Contoso-AzureDevBox-vnet"
subnetName="Contoso-AzureDevBox-subnet"
imageGalleryName="ContosoImageGallery"

# Display the planned actions for user clarity.
echo "-----------------------------------------"
echo "Azure Resource Automation Script"
echo "-----------------------------------------"
echo "Subscription ID: $subscriptionId"
echo "Resource Group: $devBoxResourceGroupName"
echo "Location: $location"
echo "VNet Name: $vnetName"
echo "Subnet Name: $subnetName"
echo "-----------------------------------------"

# Create a new resource group using the Azure CLI.
echo "Creating Resource Group..."
az group create -n $devBoxResourceGroupName -l $location

# Call an external script (CreateVNet.sh) to create the Virtual Network and subnet.
echo "Creating Virtual Network and Subnet..."
./CreateVNet.sh $devBoxResourceGroupName $location $vnetName $subnetName

# Setting up a network connection for Azure Development Center.
echo "Setting up Network Connection for Azure Development Center..."
./CreateNetworkConnection.sh $location $devBoxResourceGroupName $vnetName $subnetName $subscriptionId

echo "-----------------------------------------"
echo "Azure Resource Creation Completed!"
echo "-----------------------------------------"

# This script initializes a process to create an Azure Compute Gallery using the CreateComputeGallery.sh script.

# Notify the user about the operation being started
echo "Starting the process to create Azure Compute Gallery in resource group: $devBoxResourceGroupName and location: $location..."

# Call the CreateComputeGallery.sh script with the provided arguments
./CreateComputeGallery.sh $devBoxResourceGroupName $location $imageGalleryName

# Notify the user that the operation has been completed (assuming successful execution of CreateComputeGallery.sh)
echo "Operation completed!"

sku=FrontEndEngineerVSCode
./AddImagesToGallery.sh $imageGalleryName $frontEndEngineersImageName $location $sku $devBoxResourceGroupName $imageResourceGroupName $subscriptionId

sku=BackEndEnginneerVisualStudio
./AddImagesToGallery.sh $imageGalleryName $backEndEngineersImageName $location $sku $devBoxResourceGroupName $imageResourceGroupName $subscriptionId
