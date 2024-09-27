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

    echo "Service principal credentials"
    echo "$ghSecretBody"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create service principal."
        return 1
    fi
    
    echo "Service principal credentials"

    # Create users and assign roles
    createUsersAndAssignRole "$appId"

}

# Function to create users and assign roles
createUsersAndAssignRole() {
    local appId="$1"

    # Check if required parameter is provided
    if [[ -z "$appId" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: createUsersAndAssignRole <appId>"
        return 1
    fi

    echo "Creating users and assigning roles for appId: $appId"

    # Execute the script to create users and assign roles
    ./createUsersAndAssignRole.sh "$appId"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create users and assign roles for appId: $appId"
        return 1
    fi

    echo "Users created and roles assigned successfully for appId: $appId"
}

validateInput "$1" "$2"
generateDeploymentCredentials "$1" "$2"