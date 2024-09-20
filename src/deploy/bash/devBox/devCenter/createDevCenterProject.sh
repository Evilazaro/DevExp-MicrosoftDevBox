#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

# Print usage information
printUsage() {
    echo "Usage: $0 <location> <subscriptionId> <devBoxResourceGroupName> <devCenterName>"
}

# Validate the number of arguments
validateArguments() {
    if [ "$#" -ne 4 ]; then
        printUsage
        exit 1
    fi
}

# Create DevCenter projects in Azure
createDevCenterProjects() {
    local location="$1"
    local description="$2"
    local devCenterId="$3"
    local devBoxResourceGroupName="$4"
    local maxDevBoxesPerUser="$5"

    declare -A projects=(
        ["eShop"]="eShop"
    )

    for projectName in "${!projects[@]}"; do
        echo "Creating a new DevCenter admin project in Azure..."
        echo "Location: $location"
        echo "Dev Center ID: $devCenterId"
        echo "Resource Group Name: $devBoxResourceGroupName"
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
            echo "DevCenter admin project '${projects[$projectName]}' has been created successfully!"
        else
            echo "Error: Failed to create DevCenter admin project '${projects[$projectName]}'." >&2
            exit 2
        fi
    done
}

# Main script execution starts here
deployDevCenterProject() {
    validateArguments "$@"

    local location="$1"
    local subscriptionId="$2"
    local devBoxResourceGroupName="$3"
    local devCenterName="$4"
    local description="Sample .NET Core reference application, powered by Microsoft"
    local maxDevBoxesPerUser="10"
    local devCenterId="/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devCenters/$devCenterName"

    createDevCenterProjects "$location" "$description" "$devCenterId" "$devBoxResourceGroupName" "$maxDevBoxesPerUser"
}

deployDevCenterProject "$@"