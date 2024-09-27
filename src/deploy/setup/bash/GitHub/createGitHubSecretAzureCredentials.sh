#!/bin/bash

ghSecretBody="$1"

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

# Function to set up GitHub secret authentication
setupGitHubSecretAuthentication() {
    local ghSecretBody="$1"
    local ghSecretName="AZURE_CREDENTIALS"
    
    # Check if required parameter is provided
    if [[ -z "$ghSecretBody" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: setupGitHubSecretAuthentication <ghSecretBody>"
        return 1
    fi

    echo "Setting up GitHub secret authentication..."

    # Log in to GitHub
    loginToGitHub
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to log in to GitHub."
        return 1
    fi

    # Set the GitHub secret
    gh secret set "$ghSecretName" --body "$ghSecretBody"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to set GitHub secret: $ghSecretName"
        return 1
    fi

    echo "GitHub secret: $ghSecretName set successfully."
}

validateInput() {
    local ghSecretBody="$1"

    # Check if required parameters are provided
    if [[ -z "$ghSecretBody" ]] ; then
        echo "Error: Missing required parameters."
        echo "Usage: validateInput <ghSecretBody>"
        return 1
    fi
}

# Validate the input
validateInput "$ghSecretBody"
setupGitHubSecretAuthentication "$ghSecretBody"