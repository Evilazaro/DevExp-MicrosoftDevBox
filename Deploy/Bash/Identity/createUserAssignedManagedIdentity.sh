#!/bin/bash

# Constants
role="Owner"

# Download and process the template
downloadProcessTemplate() {
    local subscriptionId=$1
    local group=$2
    local output_file=$3
    local role_def=$4
    local template_url="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/aibroleImageCreation-template.json"

    # Download image template
    echo "Downloading image template from ${template_url}..."
    if ! wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${template_url}" -O "${output_file}"; then
        echo "Error: Failed to download the image template."
        exit 3
    fi
    echo "Successfully downloaded the image template to ${output_file}."

    # Replace placeholders in the downloaded template
    echo "Updating placeholders in the template..."
    sed -i "s/<subscriptionId>/${subscriptionId}/g" "${output_file}"
    sed -i "s/<rgName>/${group}/g" "${output_file}"
    sed -i "s/<roleName>/${role_def}/g" "${output_file}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update placeholders in the template."
        exit 4
    fi
    echo "Template placeholders updated."

    az role definition create --role-definition "${output_file}"
}

# Assign a role to the identity for a specific subscriptionId
assignRole() {
    local identity=$1
    local role=$2
    local subscriptionId=$3

    echo "Assigning '$role' role to the identity..."
    if az role assignment create --assignee "${identity}" --role "${role}" --scope /subscriptionIds/"${subscriptionId}"; then
        echo "'$role' role successfully assigned to the identity in the subscriptionId."
    else
        echo "Error: Failed to assign '$role' role to the identity."
        exit 2
    fi
}

# Extracting and displaying provided arguments
resourceGroupName="$1"
subscriptionId="$2"
identityId="$3"


outputFile="./DownloadedTempTemplates/aibroleImageCreation-template.json"
customroleDef="Azure Image Builder Image Def"

# Download and process the template
downloadProcessTemplate "$subscriptionId" "$resourceGroupName" "$outputFile" "$customroleDef"
windows365IdentityId="0af06dc6-e4b5-4f28-818e-e78e62d137a5"
currentUserName=$(az account show --query user.name -o tsv)
currentAzureLoggedUser=$(az ad user show --id $currentUserName --query id -o tsv)

# Assign the role to the identity
assignRole "$identityId" "$role" "$subscriptionId"
assignRole "$identityId" "Managed Identity Operator" "$subscriptionId"
assignRole "$identityId" "Managed Identity Operator" "$subscriptionId"
assignRole "$identityId" "$customroleDef" "$subscriptionId"
assignRole "$windows365IdentityId" "Reader" "$subscriptionId"
assignRole "$currentAzureLoggedUser" "DevCenter Dev Box User" "$subscriptionId"