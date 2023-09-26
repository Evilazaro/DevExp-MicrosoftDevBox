#!/bin/bash

# Parameters
identityResourceGroupName="$1" # Resource group of the managed identity
subscriptionId="$2"           # Azure Subscription ID
identityName="$3"             # Name of the Managed Identity
customRoleName="$4"           # Custom Role Name

# Constants
outputFile="./downloadedTempTemplates/identity/aibroleImageCreation-template.json"
windows365identityName="0af06dc6-e4b5-4f28-818e-e78e62d137a5"
branch="Dev"

# Derive Current User Details
currentUserName=$(az account show --query user.name -o tsv) # Azure Logged in Username
currentAzureLoggedUser=$(az ad user show --id $currentUserName --query id -o tsv) # Azure Logged in User ID
identityId=$(az identity show --name $identityName --resource-group $identityResourceGroupName --query principalId -o tsv) # Managed Identity ID

# Function to create custom role using a template
function createCustomRole() {
    local subscriptionId=$1
    local group=$2
    local outputFile=$3
    local customRoleName=$4
    
    local templateUrl="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/Deploy/ARMTemplates/identity/aibRoleImageCreation-template.json"
    
    echo "Starting custom role creation..."
    echo "Downloading image template from ${templateUrl}..."
    
    if ! wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${templateUrl}" -O "${outputFile}"; then
        echo "Error: Failed to download the image template."
        exit 3
    fi
    
    echo "Successfully downloaded the image template to ${outputFile}."
    echo "Custom Role Name is ${customRoleName}"	
    
    echo "Updating placeholders in the template..."
    sed -i "s/<subscriptionId>/${subscriptionId}/g" "${outputFile}"
    sed -i "s/<rgName>/${group}/g" "${outputFile}"
    sed -i "s/<roleName>/${customRoleName}/g" "${outputFile}"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update placeholders in the template."
        exit 4
    fi
    
    echo "Template placeholders updated."
    az role definition create --role-definition "${outputFile}"
    echo "Custom role creation completed."
}

# Function to assign a role to an identity
function assignRole() {
    local identityId=$1
    local roleName=$2
    local subscriptionId=$3

    echo "Starting role assignment..."
    echo "Assigning '$roleName' role to the identity $identityId for subscriptionId ${subscriptionId}"
    
    if az role assignment create --assignee "${identityId}" --role "${roleName}" --scope /subscriptions/"${subscriptionId}"; then
        echo "'$roleName' role successfully assigned to the identity in the subscriptionId."
    else
        echo "Error: Failed to assign '$roleName' role to the identity."
        exit 2
    fi
    echo "Role assignment completed."
}

# Main Script Execution
echo "Script started."

createCustomRole "$subscriptionId" "$identityResourceGroupName" "$outputFile" "$customRoleName"

assignRole "$identityId" "Owner" "$subscriptionId"
assignRole "$identityId" "Managed Identity Operator" "$subscriptionId"
assignRole "$identityId" "$customRoleName" "$subscriptionId"
assignRole "$windows365identityName" "Reader" "$subscriptionId"
assignRole "$currentAzureLoggedUser" "DevCenter Dev Box User" "$subscriptionId"

echo "Script completed."
