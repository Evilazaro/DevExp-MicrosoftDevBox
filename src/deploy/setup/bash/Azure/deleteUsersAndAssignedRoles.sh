#!/bin/bash

subscriptionId="$(az account show --query id -o tsv)"

# Function to delete user assignments and roles
deleteUserAssignments() {

    # Check if required parameter is provided
    if [[ -z "$currentUser" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: deleteUserAssignments <currentUser>"
        return 1
    fi

    # Get the current signed-in user's object ID
    local currentUser
    currentUser=$(az ad signed-in-user show --query id -o tsv)
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to retrieve current signed-in user's object ID."
        return 1
    fi

    echo "Deleting user assignments and roles for currentUser: $currentUser"
        
    # Remove roles from the service principal and current user
    removeRole "$currentUser" "DevCenter Project Admin" "ServicePrincipal"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to remove role 'DevCenter Project Admin' from service principal with currentUser: $currentUser"
        return 1
    fi

    removeRole "$currentUser" "DevCenter Dev Box User" "User"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to remove role 'DevCenter Dev Box User' from current user with object ID: $currentUser"
        return 1
    fi

    removeRole "$currentUser" "DevCenter Project Admin" "User"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to remove role 'DevCenter Project Admin' from current user with object ID: $currentUser"
        return 1
    fi

    echo "User assignments and role removals completed successfully for currentUser: $currentUser"
}

# Function to remove a role from a user or service principal
removeRole() {
    local userIdentityId="$1"
    local roleName="$2"
    local idType="$3"

    # Check if required parameters are provided
    if [[ -z "$userIdentityId" || -z "$roleName" || -z "$idType" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: removeRole <userIdentityId> <roleName> <idType>"
        return 1
    fi

    echo "Removing '$roleName' role from identityId $userIdentityId..."

    # Attempt to remove the role
    az role assignment delete --assignee "$userIdentityId" --role "$roleName" --scope /subscriptions/"$subscriptionId"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to remove role '$roleName' from identityId $userIdentityId."
        return 2
    fi

    echo "Role '$roleName' removed successfully."
}


validateInput() {
    # Check if required parameter is provided
    if [[ -z "$appDisplayName" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: deleteDeploymentCredentials <appDisplayName>"
        return 1
    fi
    currentUser=$(az ad sp list --display-name "$appDisplayName" --query "[0].currentUser" -o tsv)
}

deleteUserAssignments