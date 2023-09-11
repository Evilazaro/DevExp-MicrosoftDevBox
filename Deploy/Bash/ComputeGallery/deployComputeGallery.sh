#!/bin/bash

# This script automates the process of creating a resource in Azure.
# It takes three input arguments: gallery name, location, and resource group name,
# and uses them to execute the appropriate Azure CLI command.

# Exit immediately if any command exits with a non-zero status, and also if any variable is undeclared
set -euo pipefail

# Function to display the usage of the script
usage() {
    echo "Usage: $0 <galleryName> <location> <resourceGroupName>"
    echo "Example: $0 myGallery eastus myResourceGroup"
    exit 1
}

# Function to validate the input arguments
validate_input() {
    if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
        echo "Error: All arguments must have a value."
        usage
    fi
}

# Check for correct number of arguments and validate input
if [[ "$#" -ne 3 ]]; then
    echo "Error: Incorrect number of arguments provided."
    usage
else
    validate_input "$@"
fi

# Assign input arguments to descriptive variable names for better clarity
galleryName="$1"
location="$2"
resourceGroupName="$3"

# Display progress to the user
echo "----------------------------------------------"
echo "Gallery Name: $galleryName"
echo "Location: $location"
echo "Resource Group: $resourceGroupName"
echo "----------------------------------------------"
echo "Creating resource in Azure with the provided details..."

# Execute the Azure command to create the resource
az sig create \
    --gallery-name "$galleryName" \
    --resource-group "$resourceGroupName" \
    --location "$location" \
    --tags  "division=Contoso-Platform" \
            "Environment=DevWorkstationService-Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=eShopOnContainers" 

# If the command succeeds, print a success message
if [[ $? -eq 0 ]]; then
    echo "----------------------------------------------"
    echo "Operation completed successfully!"
else
    # If the command fails, print an error message and exit with a non-zero status
    echo "Error: Operation failed."
    exit 1
fi
