#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Check if necessary parameters are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 poolName devBoxName devCenterName projectName"
    exit 1
fi

# Assign command line arguments to variables with meaningful names
poolName="$1"
devBoxName="$2"
devCenterName="$3"
projectName="$4"

echo "Initializing script..."

# Retrieve the current user's name
echo "Retrieving the current Azure user name..."
currentUserName=$(az account show --query user.name -o tsv)

if [ -z "$currentUserName" ]; then
    echo "Failed to retrieve current user name. Exiting..."
    exit 1
fi

echo "Current user name is: $currentUserName"

# Get the Azure Active Directory ID of the current user
echo "Retrieving the Azure AD ID of the current user..."
currentAzureLoggedUser=$(az ad user show --id "$currentUserName" --query id -o tsv)

if [ -z "$currentAzureLoggedUser" ]; then
    echo "Failed to retrieve Azure AD ID of the current user. Exiting..."
    exit 1
fi

echo "Azure AD ID of the current user is: $currentAzureLoggedUser"

# Create a new development box in the specified pool, development center and project
echo "Creating a new development box..."
az devcenter dev dev-box create \
    --pool-name "$poolName" \
    --name "$devBoxName" \
    --dev-center-name "$devCenterName" \
    --project-name "$projectName" \
    --user-id "$currentAzureLoggedUser" \
    --local-administrator Enabled 


az devcenter dev dev-box restart \
    --name "$devBoxName" \
    --dev-center-name "$devCenterName" \
    --project-name "$projectName" \
    --user-id "$currentAzureLoggedUser" 

echo "Development box created successfully!"

# Exit the script
exit 0
