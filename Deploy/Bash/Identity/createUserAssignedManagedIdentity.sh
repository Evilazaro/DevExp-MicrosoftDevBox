#!/bin/bash

# -----------------------------------------------------------------------------
# Script to assign a role to a User-Assigned Managed Identity in Azure
# -----------------------------------------------------------------------------

# Constants
ROLE="Owner"

# Print usage message
usage() {
    echo "Usage: $0 <Resource Group> <Subscription ID> <Identity ID>"
}

# Check the number of arguments provided to the script
check_args() {
    if [ "$#" -ne 3 ]; then
        echo "Error: You must provide exactly 3 arguments."
        usage
        exit 1
    fi
}

# Print a header for better output readability
print_header() {
    local header=$1
    echo "-------------------------------------------------------------"
    echo "$header"
    echo "-------------------------------------------------------------"
}

# Download and process the template
download_and_process_template() {
    local subscription=$1
    local group=$2
    local output_file=$3
    local role_def=$4
    local template_url="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/aibRoleImageCreation-template.json"

    # Download image template
    echo "Downloading image template from ${template_url}..."
    if ! wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${template_url}" -O "${output_file}"; then
        echo "Error: Failed to download the image template."
        exit 3
    fi
    echo "Successfully downloaded the image template to ${output_file}."

    # Replace placeholders in the downloaded template
    echo "Updating placeholders in the template..."
    sed -i "s/<subscriptionID>/${subscription}/g" "${output_file}"
    sed -i "s/<rgName>/${group}/g" "${output_file}"
    sed -i "s/<roleName>/${role_def}/g" "${output_file}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update placeholders in the template."
        exit 4
    fi
    echo "Template placeholders updated."

    az role definition create --role-definition "${output_file}"
}

# Assign a role to the identity for a specific subscription
assign_role() {
    local identity=$1
    local role=$2
    local subscription=$3

    echo "Assigning '$role' role to the identity..."
    if az role assignment create --assignee "${identity}" --role "${role}" --scope /subscriptions/"${subscription}"; then
        echo "'$role' role successfully assigned to the identity in the subscription."
    else
        echo "Error: Failed to assign '$role' role to the identity."
        exit 2
    fi
}

# Main script execution
check_args "$@"

print_header "Creating a User-Assigned Managed Identity & Granting Permissions"

# Extracting and displaying provided arguments
resourceGroupName="$1"
subscriptionID="$2"
identityId="$3"

# Displaying the input details for confirmation
echo "Details Provided:"
echo "Resource Group: $resourceGroupName"
echo "Subscription ID: $subscriptionID"
echo "Identity ID: $identityId"
echo "-------------------------------------------------------------"

outputFile="./DownloadedTempTemplates/aibRoleImageCreation-template.json"
customRoleDef="Azure Image Builder Image Def"

# Download and process the template
download_and_process_template "$subscriptionID" "$resourceGroupName" "$outputFile" "$customRoleDef"
windows365IdentityId="0af06dc6-e4b5-4f28-818e-e78e62d137a5"
currentUserName=$(az account show --query user.name -o tsv)
currentAzureLoggedUser=$(az ad user show --id $currentUserName --query id -o tsv)

# Assign the role to the identity
assign_role "$identityId" "$ROLE" "$subscriptionID"
assign_role "$identityId" "Managed Identity Operator" "$subscriptionID"
assign_role "$identityId" "Managed Identity Operator" "$subscriptionID"
assign_role "$identityId" "$customRoleDef" "$subscriptionID"
assign_role "$windows365IdentityId" "Reader" "$subscriptionID"
assign_role "$currentAzureLoggedUser" "DevCenter Dev Box User" "$subscriptionID"

az ad user list --query "[?contains(userPrincipalName, 'evilazaro')].objectId" -o tsv | xargs -I {} az role assignment create --assignee {} --role "DevCenter Dev Box User" --scope /subscriptions/"${subscriptionID}"

