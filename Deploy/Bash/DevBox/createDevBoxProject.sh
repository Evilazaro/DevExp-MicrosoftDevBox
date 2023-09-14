#!/usr/bin/env bash

# Check if the required number of arguments are passed, if not exit with an error message
if [ "$#" -ne 4 ]; then
    echo "Error: Invalid number of arguments."
    echo "Usage: $0 <location> <subscriptionId> <resourceGroupName> <devCenterName>"
    exit 1
fi

# Assign arguments to variables with descriptive names
location="$1"
subscriptionId="$2"
resourceGroupName="$3"
devCenterName="$4"

# Echo a message to inform the user about the start of the project creation process
echo "Starting the Azure Dev Center project creation process..."

# Create a Dev Center project using the az CLI
az devcenter admin project create \
    --location "$location" \
    --description "Sample .NET Core reference application, powered by Microsoft" \
    --dev-center-id "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName" \
    --name "eShop" \
    --resource-group "$resourceGroupName" \
    --max-dev-boxes-per-user "10" \
    --tags  "division=Contoso-Platform" \
            "Environment=Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "division=Contoso-Platform" \
            "solution=eShop" \
            "businessUnit=e-Commerce"


# Check the exit status of the last command and echo a corresponding message
if [ $? -eq 0 ]; then
    echo "Project creation was successful."
else
    echo "Project creation failed. Please check the inputs and try again."
fi
