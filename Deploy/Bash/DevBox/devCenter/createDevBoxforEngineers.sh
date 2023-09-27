#!/bin/bash

# Check if the correct number of arguments has been provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <poolName> <devBoxName> <devCenterName> <projectName>"
    exit 1
fi

# Assign command line arguments to variables with meaningful names
poolName="$1"
devBoxName="$2"
devCenterName="$3"
projectName="$4"

# Inform the user about the values received
echo "Creating Dev Box with:"
echo "Pool Name: $poolName"
echo "Dev Box Name: $devBoxName"
echo "Dev Center Name: $devCenterName"
echo "Project Name: $projectName"

# Obtain the current Azure logged user name and ID
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

# Create a dev box with specified parameters
echo "Creating Dev Box..."
az devcenter dev dev-box create \
    --pool-name "$poolName" \
    --name "$devBoxName" \
    --dev-center-name "$devCenterName" \
    --project-name "$projectName" \
    --user-id "$currentAzureLoggedUserID" \
    --no-wait

# Check if the dev box creation was successful
if [ "$?" -eq 0 ]; then
    echo "Dev Box '$devBoxName' has been created successfully!"
else
    echo "Error: Dev Box creation failed."
    exit 1
fi
