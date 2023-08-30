#!/bin/bash

# Exit on any non-zero command to ensure the script stops if there's a problem
set -e

# Function to display the usage of the script
usage() {
    echo "Usage: $0 <galleryName> <location> <galleryResourceGroup>"
    echo "Example: $0 myGallery eastus myResourceGroup"
    exit 1
}

# Check for correct number of arguments
if [[ "$#" -ne 3 ]]; then
    echo "Error: Incorrect number of arguments provided."
    usage
fi

# Assign input arguments to descriptive variable names for better clarity
galleryName="$1"
location="$2"
galleryResourceGroup="$3"

# Display progress to the user
echo "----------------------------------------------"
echo "Gallery Name: $galleryName"
echo "Location: $location"
echo "Resource Group: $galleryResourceGroup"
echo "----------------------------------------------"
echo "Creating resource in Azure with the provided details..."

# Execute the Azure command to create the resource
az sig create \
    --gallery-name "$galleryName" \
    --resource-group "$galleryResourceGroup" \
    --location "$location" \
    --tags  "division=Contoso-Platform" \
            "Environment=DevWorkstationService-Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=eShopOnContainers" 

# Notify the user that the entire operation has been completed successfully
echo "----------------------------------------------"
echo "Operation completed successfully!"
