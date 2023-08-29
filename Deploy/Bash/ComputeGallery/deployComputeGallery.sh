#!/bin/bash

# Exit on any error to ensure the script stops if there's a problem
set -e

# Check if the correct number of arguments are provided
if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 <galleryName> <location> <galleryResourceGroup>"
    exit 1
fi

# Assign input arguments to descriptive variable names
galleryName="$1"
location="$2"
galleryResourceGroup="$3"

# Notify the user that the resource is about to be created in Azure
echo "Creating resource in Azure with the provided details..."

az sig create \
    --gallery-name "$galleryName" \
    --resource-group "$galleryResourceGroup" \
    --location "$location"

# Notify the user that the entire operation has been completed
echo "Operation completed successfully!"
