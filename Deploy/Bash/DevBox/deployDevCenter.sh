#!/bin/bash
# Script to create Azure Dev Center with user-assigned identity and specified tags.

# Ensure the script exits if any command fails.
set -e

# Ensure the script treats undefined variables as errors and reports them.
set -u

# Ensure the script will not hide errors inside pipelines.
set -o pipefail

# Check for the required number of arguments.
if [[ $# -lt 5 ]]; then
  echo "Usage: $0 <devCenterName> <devCenterResourceGroup> <location> <identityName> <subscriptionId>"
  exit 1
fi

# Assigning passed arguments to meaningful variable names.
devCenterName="$1"
devCenterResourceGroup="$2"
location="$3"
identityName="$4"
subscriptionId="$5"

# Constructing the user-assigned-identity string.
identityPath="/subscriptions/$subscriptionId/resourceGroups/$devCenterResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$identityName"
userAssignedIdentity="{\"$identityPath\":{}}"

echo "Creating Azure Dev Center: $devCenterName..."

# Executing Azure CLI command to create the Dev Center.
az devcenter admin devcenter create \
    --name "$devCenterName" \
    --resource-group "$devCenterResourceGroup" \
    --location "$location" \
    --identity-type "UserAssigned" \
    --user-assigned-identity "$userAssignedIdentity" \
    --tags "division=Contoso-Platform" \
           "Environment=DevWorkstationService-Prod" \
           "offer=Contoso-DevWorkstation-Service" \
           "Team=eShopOnContainers"

# Output success message upon completion.
echo "Azure Dev Center: $devCenterName created successfully!"
