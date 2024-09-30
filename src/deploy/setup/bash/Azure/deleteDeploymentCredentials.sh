#!/bin/bash

appDisplayName="$1"

deleteDeploymentCredentials() {
    local appDisplayName="$1"

    appId=$(az ad app list --display-name "$appDisplayName" --query "[0].appId" -o tsv)
    # Delete the service principal
    az ad sp delete --id "$appId"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to delete service principal."
        return 1
    fi
    az ad app delete --id "$appId"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to delete service principal."
        return 1
    fi

    echo "Service principal and App Registration deleted successfully."
}

validateInput() {
    # Check if required parameter is provided
    if [[ -z "$appDisplayName" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: deleteDeploymentCredentials <appDisplayName>"
        return 1
    fi
}

deleteDeploymentCredentials "$appDisplayName"