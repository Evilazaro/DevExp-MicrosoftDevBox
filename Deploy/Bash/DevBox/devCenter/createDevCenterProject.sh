#!/bin/bash

# This script creates a devcenter admin project in Azure, applying several tags.

# Define variables
location="$1"
subscriptionId="$2"
devBoxResourceGroupName="$3"
devCenterName="$4"
description="Sample .NET Core reference application, powered by Microsoft"
projectName="eShop"
maxDevBoxesPerUser="10"

# Print usage information if not enough arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <location> <subscriptionId> <devBoxResourceGroupName> <devCenterName>"
    exit 1
fi

# Construct the dev-center-id
devCenterId="/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName"

# Inform the user about the action to be performed
echo "Creating a new devcenter admin project in Azure..."
echo "Location: $location"
echo "Subscription ID: $subscriptionId"
echo "Resource Group Name: $devBoxResourceGroupName"
echo "Dev Center Name: $devCenterName"
echo "Description: $description"
echo "Project Name: $projectName"
echo "Max Dev Boxes Per User: $maxDevBoxesPerUser"

# Run the Azure CLI command to create a devcenter admin project
az devcenter admin project create \
    --location "$location" \
    --description "$description" \
    --dev-center-id "$devCenterId" \
    --name "$projectName" \
    --resource-group "$devBoxResourceGroupName" \
    --max-dev-boxes-per-user "$maxDevBoxesPerUser" \
    --tags  "division=Contoso-Platform" \
            "Environment=Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "solution=eShop" \
            "businessUnit=e-Commerce"

# Check the status of the last command run and inform the user
if [ $? -eq 0 ]; then
    echo "Devcenter admin project '$projectName' has been created successfully!"
else
    echo "Failed to create devcenter admin project '$projectName'." >&2
    exit 2
fi
