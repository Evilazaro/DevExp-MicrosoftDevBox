#!/bin/bash

ghSecretName="$1"

deleteGhSecret() {
    local ghSecretName="$1"

    # Check if required parameter is provided
    if [[ -z "$ghSecretName" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: deleteGhSecret <ghSecretName>"
        return 1
    fi

    echo "Deleting GitHub secret: $ghSecretName"

    # Delete the GitHub secret
    gh secret remove "$ghSecretName"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to delete GitHub secret: $ghSecretName"
        return 1
    fi

    echo "GitHub secret: $ghSecretName deleted successfully."
}

validateInput() {
    local ghSecretName="$1"

    # Check if required parameters are provided
    if [[ -z "$ghSecretName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: validateInput <ghSecretName>"
        return 1
    fi
}

# Function to log in to GitHub using the GitHub CLI
loginToGitHub() {
    echo "Logging in to GitHub using GitHub CLI..."

    # Attempt to log in to GitHub
    gh auth login
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to log in to GitHub."
        return 1
    fi

    echo "Successfully logged in to GitHub."
}

deleteGhSecret "$ghSecretName"