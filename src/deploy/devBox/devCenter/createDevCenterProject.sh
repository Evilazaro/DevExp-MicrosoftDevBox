#!/bin/bash

# This script creates a devCenter admin project in Azure, applying several tags.

# Print usage if not enough arguments are provided
function printUsage() {
    echo "Usage: $0 <location> <subscriptionId> <devBoxResourceGroupName> <devCenterName>"
}

# Create devCenter projects in Azure
function createDevCenterProjects() {
    local location="$1"
    local description="$2"
    local devCenterId="$3"
    local devBoxResourceGroupName="$4"
    local maxDevBoxesPerUser="$5"

    declare -A projects=(
        ["eShop"]="eShop"
        ["Contoso"]="Contoso"
    )

    for projectName in "${!projects[@]}"; do
        echo "Creating a new devCenter admin project in Azure..."
        echo "Location: $location"
        echo "Subscription ID: $subscriptionId"
        echo "Resource Group Name: $devBoxResourceGroupName"
        echo "Dev Center Name: $devCenterName"
        echo "Description: $description"
        echo "Project Name: ${projects[$projectName]}"
        echo "Max Dev Boxes Per User: $maxDevBoxesPerUser"

        az devcenter admin project create \
            --location "$location" \
            --description "$description" \
            --dev-center-id "$devCenterId" \
            --name "${projects[$projectName]}" \
            --resource-group "$devBoxResourceGroupName" \
            --max-dev-boxes-per-user "$maxDevBoxesPerUser" \
            --tags  "division=petv2-Platform" \
                    "Environment=Prod" \
                    "offer=petv2-DevWorkstation-Service" \
                    "Team=Engineering" \
                    "solution=${projects[$projectName]}" \
                    "businessUnit=e-Commerce"

        if [ $? -eq 0 ]; then
            echo "DevCenter admin project '$projectName' has been created successfully!"
        else
            echo "Failed to create devCenter admin project '$projectName'." >&2
            exit 2
        fi
    done
}

# Main script execution starts here
if [ "$#" -ne 4 ]; then
    printUsage
    exit 1
fi

location="$1"
subscriptionId="$2"
devBoxResourceGroupName="$3"
devCenterName="$4"
description="Sample .NET Core reference application, powered by Microsoft"
maxDevBoxesPerUser="10"
devCenterId="/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devCenters/$devCenterName"

createDevCenterProjects "$location" "$description" "$devCenterId" "$devBoxResourceGroupName" "$maxDevBoxesPerUser"
