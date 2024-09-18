#!/bin/bash

set -e
set -u

# Constants
readonly branch="main"
readonly outputFilePath="../downloadedTempTemplates/identity/roleImage.json"
readonly templateUrl="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/identity/roleImage.json"

# Parameters
readonly identityResourceGroupName="$1"
readonly subscriptionId="$2"
readonly identityName="$3"
readonly customRoleName="$4"

# Derive current user details
currentUser=$(az account show --query user.name -o tsv)
currentAzureUserId=$(az ad user show --id "$currentUser" --query objectId -o tsv)
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
    sed -i "<subscriptionId>/$subscriptionId/g" "$outputFilePath"
    sed -i "<rgName>/$identityResourceGroupName/g" "$outputFilePath"
    sed -i "<customRoleName>/$customRoleName/g" "$outputFilePath"
    
    if [ $? -ne 0 ]; then
        echo "Error updating placeholders."
        exit 4
    fi
    
    az role definition create --role-definition "$outputFilePath"

    while [ "$(az role definition list --name "$customRoleName" --query [].customRoleName -o tsv)" != "$customRoleName" ]; do
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

    echo "Assigning '$roleName' role to identityId $identityId..."
    
    if az role assignment create --assignee-object-identityId "$identityId" --assignee-principal-type "$idType" --role "$roleName" --scope /subscriptions/"$subscriptionId"; then
        echo "Role '$roleName' assigned."
    else
        echo "Error assigning '$roleName'."
        exit 2
    fi
}

# Main script execution
echo "Script started."

createCustomRole

# Assign roles
assignRole "$identityId" "Virtual Machine Contributor" "ServicePrincipal"
assignRole "$identityId" "Desktop Virtualization Contributor" "ServicePrincipal"
assignRole "$identityId" "Desktop Virtualization Virtual Machine Contributor" "ServicePrincipal"
assignRole "$identityId" "Desktop Virtualization Workspace Contributor" "ServicePrincipal"
assignRole "$identityId" "Compute Gallery Sharing Admin" "ServicePrincipal"
assignRole "$identityId" "Virtual Machine Local User Login" "ServicePrincipal"
assignRole "$identityId" "Managed Identity Operator" "ServicePrincipal"
assignRole "$identityId" "$customRoleName" "ServicePrincipal"
assignRole "$currentAzureUserId" "DevCenter Dev Box User" "User"

echo "Script completed."