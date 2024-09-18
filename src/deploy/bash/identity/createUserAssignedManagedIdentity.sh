#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
# Treat unset variables as an error
set -o nounset
# Prevent errors in a pipeline from being masked
set -o pipefail

# Constants
readonly BRANCH="main"
readonly OUTPUT_FILE_PATH="../downloadedTempTemplates/identity/roleImage.json"
readonly TEMPLATE_URL="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$BRANCH/src/deploy/ARMTemplates/identity/roleImage.json"

# Function to display usage information
usage() {
    echo "Usage: $0 <identityResourceGroupName> <subscriptionId> <identityName> <customRoleName>"
    exit 1
}

# Function to check if required arguments are provided
checkArguments() {
    if [ "$#" -ne 4 ]; then
        echo "Error: Invalid number of arguments."
        usage
    fi
}

# Function to create a custom role
createCustomRole() {
    local subscriptionId="$1"
    local resourceGroupName="$2"
    local roleName="$3"

    echo "Starting custom role creation..."
    echo "Downloading image template..."

    if ! wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "$TEMPLATE_URL" -O "$OUTPUT_FILE_PATH"; then
        echo "Error: Failed to download the image template."
        exit 3
    fi

    echo "Template downloaded to $OUTPUT_FILE_PATH."
    echo "Role Name: $roleName"

    echo "Updating placeholders in the template..."
    sed -i "s/<subscriptionId>/$subscriptionId/g" "$OUTPUT_FILE_PATH"
    sed -i "s/<rgName>/$resourceGroupName/g" "$OUTPUT_FILE_PATH"
    sed -i "s/<roleName>/$roleName/g" "$OUTPUT_FILE_PATH"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to update placeholders."
        exit 4
    fi

    if az role definition create --role-definition "$OUTPUT_FILE_PATH"; then
        while [ "$(az role definition list --name "$roleName" --query [].roleName -o tsv)" != "$roleName" ]; do
            echo "Waiting for the role to be created..."
            sleep 10
        done
        echo "Custom role creation completed."
    else
        echo "Error: Failed to create custom role."
        exit 5
    fi
    echo "Waiting for the role to be created..."
    sleep 10
}

# Function to assign a role to an identity
assignRole() {
    local roleName="$1"
    local idType="$2"
    local assigneeId="$3"
    local subscriptionId="$4"
    local customRole="$5"

    echo "Assigning '$roleName' role to ID $assigneeId..."

    if [ "$customRole" = true ]; then
        while [ "$(az role definition list --name "$roleName" --query [].roleName -o tsv)" != "$roleName" ]; do
            echo "Checking if the role is created..."
            sleep 10
        done
    fi

    if az role assignment create --assignee-object-id "$assigneeId" --assignee-principal-type "$idType" --role "$roleName" --scope /subscriptions/"$subscriptionId"; then
        echo "Role '$roleName' assigned."
    else
        echo "Error: Failed to assign role '$roleName'."
        exit 2
    fi
}

# Main script execution
createUserAssignedManagedIdentity() {
    echo "Script started."

    checkArguments "$@"

    local identityResourceGroupName="$1"
    local subscriptionId="$2"
    local identityName="$3"
    local customRoleName="$4"

    local currentUser
    local currentAzureUserId
    local identityId

    currentUser=$(az account show --query user.name -o tsv)
    currentAzureUserId=$(az ad user show --id "$currentUser" --query id -o tsv)
    identityId=$(az identity show --name "$identityName" --resource-group "$identityResourceGroupName" --query principalId -o tsv)

    createCustomRole "$subscriptionId" "$identityResourceGroupName" "$customRoleName"

    assignRole "Virtual Machine Contributor" "ServicePrincipal" "$identityId" "$subscriptionId" false
    assignRole "Desktop Virtualization Contributor" "ServicePrincipal" "$identityId" "$subscriptionId" false
    assignRole "Desktop Virtualization Virtual Machine Contributor" "ServicePrincipal" "$identityId" "$subscriptionId" false
    assignRole "Desktop Virtualization Workspace Contributor" "ServicePrincipal" "$identityId" "$subscriptionId" false
    assignRole "Compute Gallery Sharing Admin" "ServicePrincipal" "$identityId" "$subscriptionId" false
    assignRole "Virtual Machine Local User Login" "ServicePrincipal" "$identityId" "$subscriptionId" false
    assignRole "Managed Identity Operator" "ServicePrincipal" "$identityId" "$subscriptionId" false
    assignRole "$customRoleName" "ServicePrincipal" "$identityId" "$subscriptionId" true
    assignRole "DevCenter Dev Box User" "User" "$currentAzureUserId" "$subscriptionId" false

    echo "Script completed."
}

# Execute the main function with all script arguments
createUserAssignedManagedIdentity "$@"