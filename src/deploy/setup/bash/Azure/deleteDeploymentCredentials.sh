#!/bin/bash

appId="$1"

deleteDeploymentCredentials() {
    local appId="$1"

    # Delete the service principal
    az ad sp delete --id "$appId"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to delete service principal."
        return 1
    fi

    echo "Service principal deleted successfully."
}

validateInput() {
    # Check if required parameter is provided
    if [[ -z "$appId" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: deleteDeploymentCredentials <appId>"
        return 1
    fi
}

deleteDeploymentCredentials "$appId"