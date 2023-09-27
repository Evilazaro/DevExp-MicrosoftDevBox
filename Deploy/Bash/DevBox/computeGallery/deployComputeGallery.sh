#!/bin/bash

# Exit immediately if a command exits with a non-zero status, and treat unset variables as an error.
set -euo pipefail

# Check if the correct number of arguments are passed, if not, exit with an error message
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <ComputeGalleryName> <Location> <GalleryResourceGroupName>"
    exit 1
fi

# Assigning input arguments to descriptive variable names for better clarity and readability
computeGalleryName="$1"
location="$2"
galleryResourceGroupName="$3"

# Informing the user about the start of resource creation
echo "Initializing the creation of a Shared Image Gallery named '$computeGalleryName' in resource group '$galleryResourceGroupName' located in '$location'."

# Execute the Azure command to create the resource, with tags for better resource categorization and management
# Echoing the command before running it for better user awareness
echo "Executing Azure CLI command to create the Shared Image Gallery..."
az sig create \
    --gallery-name "$computeGalleryName" \
    --resource-group "$galleryResourceGroupName" \
    --location "$location" \
    --tags  "Division=Contoso-Platform" \
            "Environment=Prod" \
            "Offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "Solution=eShop" \
            "BusinessUnit=e-Commerce"

# Confirming the successful creation of the resource
echo "Shared Image Gallery '$computeGalleryName' successfully created in resource group '$galleryResourceGroupName' located in '$location'."
