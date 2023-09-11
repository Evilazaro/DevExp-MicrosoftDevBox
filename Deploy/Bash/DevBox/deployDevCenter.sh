#!/bin/bash
# Script to create Azure Dev Center with user-assigned identity and specified tags.
# This script accepts five parameters: devCenterName, resourceGroupName, location, identityName, and subscriptionId.

# Function to display the usage of the script.
usage() {
  echo "Usage: $0 <devCenterName> <resourceGroupName> <location> <identityName> <subscriptionId>"
}

# Function to create an Azure Dev Center.
create_dev_center() {
  local devCenterName="$1"
  local resourceGroupName="$2"
  local location="$3"
  local identityName="$4"
  local subscriptionId="$5"

  # Constructing the user-assigned-identity string.
  local identityPath="/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$identityName"
  local userAssignedIdentity="{\"$identityPath\":{}}"


  # Download Dev Center template file
  devCenterTemplateFile=""
  echo "Downloading image template from ${devCenterTemplateFile}..."
  wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${devCenterTemplateFile}" -O "${outputFile}"
  echo "Successfully downloaded the image template to ${outputFile}."

  echo "Creating Azure Dev Center: $devCenterName..."

  # Executing Azure CLI command to create the Dev Center.
  az devcenter admin devcenter create \
      --name "$devCenterName" \
      --resource-group "$resourceGroupName" \
      --location "$location" \
      --identity-type "UserAssigned" \
      --user-assigned-identities "$userAssignedIdentity" \
      --tags "division=Contoso-Platform" \
             "Environment=DevWorkstationService-Prod" \
             "offer=Contoso-DevWorkstation-Service" \
             "Team=eShopOnContainers"

  # Output success message upon completion.
  echo "Azure Dev Center: $devCenterName created successfully!"
}

# Ensure the script exits if any command fails.
set -e

# Ensure the script treats undefined variables as errors and reports them.
set -u

# Ensure the script will not hide errors inside pipelines.
set -o pipefail

# Check for the required number of arguments.
if [[ $# -lt 5 ]]; then
  usage
  exit 1
fi

# Call the create_dev_center function with the provided arguments.
create_dev_center "$@"
