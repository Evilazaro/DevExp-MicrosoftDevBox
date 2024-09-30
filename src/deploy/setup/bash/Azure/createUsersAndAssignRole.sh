#!/bin/bash

subscriptionId=$(az account show --query id -o tsv)

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
   
    # Get the current signed-in user's object ID
    local currentUser
    currentUser=$(az ad signed-in-user show --query id -o tsv)
    
    echo "Creating user assignments and assigning roles for currentUser: $currentUser"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to retrieve current signed-in user's object ID."
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

    echo "User assignments and role assignments completed successfully for currentUser: $currentUser"
}

createUserAssignments