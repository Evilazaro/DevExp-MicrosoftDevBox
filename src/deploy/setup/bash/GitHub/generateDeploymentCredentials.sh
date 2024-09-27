#!/bin/bash

# Function to generate deployment credentials
generateDeploymentCredentials() {
    local appName="$1"
    local displayName="$2"
    local role
    local subscriptionId

    # Validate the input
    validateInput "$appName" "$displayName"

    # Define the role and get the subscription ID
    role="Owner"
    subscriptionId=$(az account show --query id --output tsv)
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to retrieve subscription ID."
        return 1
    fi

    # Create the service principal and capture the appId
    ghSecretBody=$(az ad sp create-for-rbac --name "$appName" --display-name "$displayName" --role "$role" --scopes "/subscriptions/$subscriptionId" --json-auth --output json)

    echo "Service principal credentials"
    echo "$ghSecretBody"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create service principal."
        return 1
    fi
    
    echo "Service principal credentials"

    # Setup GitHub secret authentication
    setupGitHubSecretAuthentication "$ghSecretBody"
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
    if [[ -z "$1" ]]; then
        echo "Error: Service principal name is required."
        return 1
    fi

    if [[ -z "$2" ]]; then
        echo "Error: Display name is required."
        return 1
    fi
}

# Call the function with the provided service principal name
generateDeploymentCredentials "$1" "$2"