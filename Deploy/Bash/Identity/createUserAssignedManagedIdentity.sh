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

# Assign a role to the identity for a specific subscription
assign_role() {
    local identity=$1
    local role=$2
    local subscription=$3

    echo "Assigning '$role' role to the identity..."
    if az role assignment create --assignee "$identity" --role "$role" --scope /subscriptions/"$subscription"; then
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
imageResourceGroup="$1"
subscriptionID="$2"
identityId="$3"

# Displaying the input details for confirmation
echo "Details Provided:"
echo "Resource Group: $imageResourceGroup"
echo "Subscription ID: $subscriptionID"
echo "Identity ID: $identityId"
echo "-------------------------------------------------------------"

customRoleTemplate="https://raw.githubusercontent.com/azure/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json"
outputFile="./DownloadedTempTemplates/aibRoleImageCreation-template.json"
imageRoleDef="Azure Image Builder Image Def"

# Download image template
echo "Downloading image template from ${customRoleTemplate}..."
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${customRoleTemplate}" -O "${outputFile}"
echo "Successfully downloaded the image template to ${outputFile}."

# Replace placeholders in the downloaded template
echo "Updating placeholders in the template..."
sed -i "s/<subscriptionID>/$subscriptionID/g" "$outputFile"
sed -i "s/<rgName>/$imageResourceGroup/g" "$outputFile"
sed -i "s/Azure Image Builder Service Image Creation Role/$imageRoleDef/g" "$outputFile"
echo "Template placeholders updated."

az role definition create --role-definition "$outputFile"

# Assign the role to the identity
assign_role "$identityId" "$ROLE" "$subscriptionID"
assign_role "$identityId" "Managed Identity Operator" "$subscriptionID"
assign_role "$identityId" "$imageRoleDef" "$subscriptionID"
