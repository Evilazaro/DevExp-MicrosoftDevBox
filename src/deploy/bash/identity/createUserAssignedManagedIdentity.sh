#!/bin/bash

set -e
set -u

# Constants
readonly branch="main"
readonly outputFilePath="../downloadedTempTemplates/identity/roleImage.json"
readonly templateUrl="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/identity/roleImage.json"
readonly identityResourceGroupName="$1"
readonly subscriptionId="$2"
readonly identityName="$3"
readonly customRoleName="$4"
readonly location="$5"

# Derive current user details
currentUser=$(az ad signed-in-user show --query id -o tsv)
identityId=$(az identity show --name "$identityName" --resource-group "$identityResourceGroupName" --query principalId -o tsv)

# Function to create a custom role using a template
createCustomRole() {
   
    echo "Starting custom role creation..."
    echo "Downloading image template..."
    
    if ! wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "$templateUrl" -O "$outputFilePath"; then
        echo "Error: Failed to download the image template."
        exit 3
    fi
    
    echo "Template downloaded to $outputFilePath."
    echo "Role Name: $customRoleName"
    
    echo "Updating placeholders in the template..."
    sed -i "s/<subscriptionId>/$subscriptionId/g" "$outputFilePath"
    sed -i "s/<rgName>/$identityResourceGroupName/g" "$outputFilePath"
    sed -i "s/<roleName>/$customRoleName/g" "$outputFilePath"
    
    if [ $? -ne 0 ]; then
        echo "Error updating placeholders."
        exit 4
    fi
    
    az role definition create --role-definition "$outputFilePath"

    while [ "$(az role definition list --name "$customRoleName")" != "[]" ]; do
        echo "Waiting for the role to be created..."
        sleep 10
    done 
    
    echo "Custom role creation completed."
}

# Function to assign a role to an identity
assignRole() {
    local userIdentityId="$1"
    local roleName="$2"
    local idType="$3"

    echo "Assigning '$roleName' role to identityId $userIdentityId..."
    
    if az role assignment create --assignee-object-id "$userIdentityId" --assignee-principal-type "$idType" --role "$roleName" --scope /subscriptions/"$subscriptionId"; then
        echo "Role '$roleName' assigned."
    else
        echo "Error assigning '$roleName'."
        exit 2
    fi
}

createUserAssignedManagedIdentity()
{
    echo "Creating identity '$identityName' in resource group '$identityResourceGroupName' located in '$location'..."

    createCustomRole 

    # Assign roles
    assignRole "$identityId" "$customRoleName" "ServicePrincipal"
    assignRole "$currentUser" "DevCenter Dev Box User" "User"

}

createUserAssignedManagedIdentity "$@"