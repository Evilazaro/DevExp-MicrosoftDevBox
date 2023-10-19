#!/bin/bash

# Define the usage of the script to inform users about expected parameters
usage() {
    echo "Usage: $0 <location> <devBoxDefinitionName> <networkConnectionName> <poolName> <projectName> <devBoxResourceGroupName>"
}

# Validate the number of arguments passed to the script
if [ "$#" -ne 6 ]; then
    echo "Error: Incorrect number of arguments"
    usage
    exit 1
fi

# Assign arguments to variables with meaningful names in camelCase
location="$1"
devBoxDefinitionName="$2"
networkConnectionName="$3"
poolName="$4"
projectName="$5"
devBoxResourceGroupName="$6"

# Function to create a DevCenter admin pool
function createDevCenterAdminPool() {
    echo "Creating DevCenter admin pool with the following parameters:"
    echo "Location: $location"
    echo "DevBox Definition Name: $devBoxDefinitionName"
    echo "Network Connection Name: $networkConnectionName"
    echo "Pool Name: $poolName"
    echo "Project Name: $projectName"
    echo "Resource Group: $devBoxResourceGroupName"
    
    az devcenter admin pool create \
        --location "$location" \
        --devbox-definition-name "$devBoxDefinitionName" \
        --network-connection-name "$networkConnectionName" \
        --pool-name "$poolName" \
        --project-name "$projectName" \
        --resource-group "$devBoxResourceGroupName" \
        --local-administrator "Enabled" \
        --tags "Division=Contoso-Platform" \
               "Environment=Prod" \
               "Offer=Contoso-DevWorkstation-Service" \
               "Team=Engineering" \
               "solution=ContosoProjects" \
               "BusinessUnit=e-Commerce"
               
    # Check the exit status of the last command and echo a message accordingly
    if [ "$?" -eq 0 ]; then
        echo "DevCenter admin pool created successfully."
    else
        echo "Failed to create DevCenter admin pool. Please check the parameters and try again."
        exit 1
    fi
}

# Call the function to create a DevCenter admin pool
createDevCenterAdminPool
