#!/bin/bash

validateInput() {
    local appName="$1"
    local displayName="$2"

    # Check if required parameters are provided
    if [[ -z "$appName" ]] || [[ -z "$displayName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: validateInput <appName> <displayName>"
        return 1
    fi
}

# Function to generate deployment credentials
generateDeploymentCredentials() {
    local appName="$1"
    local displayName="$2"
    local role
    local subscriptionId

    # Define the role and get the subscription ID
    role="Owner"
    subscriptionId=$(az account show --query id --output tsv)
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to retrieve subscription ID."
        return 1
    fi

    # Create the service principal and capture the appId
    ghSecretBody=$(az ad sp create-for-rbac --name "$appName" --display-name "$displayName" --role "$role" --scopes "/subscriptions/$subscriptionId" --json-auth --output json)
    appId=$(az ad sp list --display-name "$displayName" --query "[0].appId" -o tsv)

    echo "Service principal credentials"
    echo "$ghSecretBody"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create service principal."
        return 1
    fi
    
    echo "Service principal credentials"

    # Create users and assign roles
    createUsersAndAssignRole "$appId"

    # Create GitHub secret for Azure credentials
    createGitHubSecretAzureCredentials "$ghSecretBody"

}

# Function to create users and assign roles
createUsersAndAssignRole() {

    echo "Creating users and assigning roles"

    # Execute the script to create users and assign roles
    ./Azure/createUsersAndAssignRole.sh
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create users and assign roles"
        return 1
    fi

    echo "Users created and roles assigned successfully"
}

# Function to create a GitHub secret for Azure credentials
createGitHubSecretAzureCredentials() {
    local ghSecretBody="$1"

    # Check if required parameter is provided
    if [[ -z "$ghSecretBody" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: createGitHubSecretAzureCredentials <ghSecretBody>"
        return 1
    fi

    echo "Creating GitHub secret for Azure credentials..."

    # Execute the script to create the GitHub secret
    ./GitHub/createGitHubSecretAzureCredentials.sh "$ghSecretBody"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create GitHub secret for Azure credentials."
        return 1
    fi

    echo "GitHub secret for Azure credentials created successfully."
}

validateInput "$1" "$2"
generateDeploymentCredentials "$1" "$2"