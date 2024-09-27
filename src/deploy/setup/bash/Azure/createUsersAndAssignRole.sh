#!/bin/bash

appId="$1"

# Function to assign a role to a user or service principal
assignRole() {
    local userIdentityId="$1"
    local roleName="$2"
    local idType="$3"

    # Check if required parameters are provided
    if [[ -z "$userIdentityId" || -z "$roleName" || -z "$idType" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: assignRole <userIdentityId> <roleName> <idType>"
        return 1
    fi

    echo "Assigning '$roleName' role to identityId $userIdentityId..."

    # Attempt to assign the role
    if az role assignment create --assignee-object-id "$userIdentityId" --assignee-principal-type "$idType" --role "$roleName" --scope /subscriptions/"$subscriptionId"; then
        echo "Role '$roleName' assigned successfully."
    else
        echo "Error: Failed to assign role '$roleName' to identityId $userIdentityId."
        return 2
    fi
}

# Function to create user assignments and assign roles
createUserAssignments() {
    local appId="$1"

    # Check if required parameter is provided
    if [[ -z "$appId" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: createUserAssigned <appId>"
        return 1
    fi

    echo "Creating user assignments and assigning roles for appId: $appId"

    # Get the current signed-in user's object ID
    local currentUser
    currentUser=$(az ad signed-in-user show --query objectId -o tsv)
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to retrieve current signed-in user's object ID."
        return 1
    fi

    # Assign roles to the service principal and current user
    assignRole "$appId" "DevCenter Project Admin" "ServicePrincipal"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to assign role 'DevCenter Project Admin' to service principal with appId: $appId"
        return 1
    fi

    assignRole "$currentUser" "DevCenter Dev Box User" "User"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to assign role 'DevCenter Dev Box User' to current user with object ID: $currentUser"
        return 1
    fi

    assignRole "$currentUser" "DevCenter Project Admin" "User"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to assign role 'DevCenter Project Admin' to current user with object ID: $currentUser"
        return 1
    fi

    echo "User assignments and role assignments completed successfully for appId: $appId"
}

validateInput() {
    local appId="$1"

    # Check if required parameter is provided
    if [[ -z "$appId" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: validateInput <appId>"
        return 1
    fi
}

validateInput "$appId"
createUserAssignments "$appId"