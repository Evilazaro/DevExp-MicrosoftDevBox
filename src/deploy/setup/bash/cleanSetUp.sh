#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

appDisplayName="PetDx GitHub Actions Enterprise App"
ghSecretName="AZURE_CREDENTIALS"

# Function to clean up the setup by deleting users, credentials, and GitHub secrets
cleanSetUp() {
    local appDisplayName="$1"
    local ghSecretName="$2"

    # Check if required parameters are provided
    if [[ -z "$appDisplayName" || -z "$ghSecretName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: cleanSetUp <appDisplayName> <ghSecretName>"
        return 1
    fi

    echo "Starting cleanup process for appDisplayName: $appDisplayName and ghSecretName: $ghSecretName"

    # Delete users and assigned roles
    ./Azure/deleteUsersAndAssignedRoles.sh "$appDisplayName"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to delete users and assigned roles for appDisplayName: $appDisplayName"
        return 1
    fi

    # Delete deployment credentials
    ./Azure/deleteDeploymentCredentials.sh "$appDisplayName"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to delete deployment credentials for appDisplayName: $appDisplayName"
        return 1
    fi

    # Delete GitHub secret for Azure credentials
    ./GitHub/deleteGitHubSecretAzureCredentials.sh "$ghSecretName"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to delete GitHub secret for Azure credentials: $ghSecretName"
        return 1
    fi

    echo "Cleanup process completed successfully for appDisplayName: $appDisplayName and ghSecretName: $ghSecretName"
}

clear
cleanSetUp "$appDisplayName" "$ghSecretName"