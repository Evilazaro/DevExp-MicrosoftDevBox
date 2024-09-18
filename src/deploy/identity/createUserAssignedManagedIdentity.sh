#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
# Treat unset variables as an error
set -o nounset
# Prevent errors in a pipeline from being masked
set -o pipefail

# Constants
readonly BRANCH="main"
readonly OUTPUT_FILE_PATH="./downloadedTempTemplates/identity/roleImage.json"
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
    local subId="$1"
    local resourceGroup="$2"
    local outputFile="$3"
    local roleName="$4"

    echo "Starting custom role creation..."
    echo "Downloading image template..."

    if ! wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "$TEMPLATE_URL" -O "$outputFile"; then
        echo "Error: Failed to download the image template."
        exit 3
    fi

    echo "Template downloaded to $outputFile."
    echo "Role Name: $roleName"

    echo "Updating placeholders in the template..."
    sed -i "s/<subscriptionId>/$subId/g" "$outputFile"
    sed -i "s/<rgName>/$resourceGroup/g" "$outputFile"
    sed -i "s/<roleName>/$roleName/g" "$outputFile"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to update placeholders."
        exit 4
    fi

    if az role definition create --role-definition "$outputFile"; then
        echo "Custom role creation completed."
    else
        echo "Error: Failed to create custom role."
        exit 5
    fi
}

# Function to assign a role to an identity
assignRole() {
    local id="$1"
    local roleName="$2"
    local subId="$3"
    local idType="$4"

    echo "Assigning '$roleName' role to ID $id..."

    if az role assignment create --assignee-object-id "$id" --assignee-principal-type "$idType" --role "$roleName" --scope /subscriptions/"$subId"; then
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

    createCustomRole "$subscriptionId" "$identityResourceGroupName" "$OUTPUT_FILE_PATH" "$customRoleName"

    assignRole "$identityId" "Virtual Machine Contributor" "$subscriptionId" "ServicePrincipal"
    assignRole "$identityId" "Desktop Virtualization Contributor" "$subscriptionId" "ServicePrincipal"
    assignRole "$identityId" "Desktop Virtualization Virtual Machine Contributor" "$subscriptionId" "ServicePrincipal"
    assignRole "$identityId" "Desktop Virtualization Workspace Contributor" "$subscriptionId" "ServicePrincipal"
    assignRole "$identityId" "Compute Gallery Sharing Admin" "$subscriptionId" "ServicePrincipal"
    assignRole "$identityId" "Virtual Machine Local User Login" "$subscriptionId" "ServicePrincipal"
    assignRole "$identityId" "Managed Identity Operator" "$subscriptionId" "ServicePrincipal"
    assignRole "$identityId" "$customRoleName" "$subscriptionId" "ServicePrincipal"
    assignRole "$currentAzureUserId" "DevCenter Dev Box User" "$subscriptionId" "User"

    echo "Script completed."
}

# Execute the main function with all script arguments
createUserAssignedManagedIdentity "$@"