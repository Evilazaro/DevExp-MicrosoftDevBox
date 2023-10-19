#!/bin/bash

# Functions

checkArguments() {
    if [ "$#" -ne 4 ]; then
        echo "Usage: $0 <poolName> <devBoxName> <devCenterName> <projectName>"
        exit 1
    fi
}

assignCommandLineArguments() {
    local poolName="$1"
    local devBoxName="$2"
    local devCenterName="$3"
    local projectName="$4"

    echo "Creating Dev Box with:"
    echo "Pool Name: $poolName"
    echo "Dev Box Name: $devBoxName"
    echo "Dev Center Name: $devCenterName"
    echo "Project Name: $projectName"
}

retrieveAzureUserInfo() {
    local currentUserName
    local currentAzureLoggedUserID

    echo "Retrieving current Azure logged user information..."
    currentUserName=$(az account show --query user.name -o tsv)

    if [ -z "$currentUserName" ]; then
        echo "Error: Couldn't retrieve the current Azure user name. Exiting."
        exit 1
    fi

    echo "Current Azure User Name: $currentUserName"

    currentAzureLoggedUserID=$(az ad user show --id "$currentUserName" --query id -o tsv)

    if [ -z "$currentAzureLoggedUserID" ]; then
        echo "Error: Couldn't retrieve the current Azure user ID. Exiting."
        exit 1
    fi

    echo "Current Azure User ID: $currentAzureLoggedUserID"

    echo "$currentAzureLoggedUserID"
}

createDevBox() {
    local poolName="$1"
    local devBoxName="$2"
    local devCenterName="$3"
    local projectName="$4"
    local userId="$5"

    echo "Creating Dev Box..."
    az devcenter dev dev-box create \
        --pool-name "$poolName" \
        --name "$devBoxName" \
        --dev-center-name "$devCenterName" \
        --project-name "$projectName" \
        --user-id "$userId"

    if [ "$?" -eq 0 ]; then
        echo "Dev Box '$devBoxName' has been created successfully!"
    else
        echo "Error: Dev Box creation failed."
        exit 1
    fi
}

# Main execution flow

checkArguments "$@"
assignCommandLineArguments "$@"
currentAzureUserId=$(retrieveAzureUserInfo)
createDevBox "$1" "$2" "$3" "$4" "$currentAzureUserId"
