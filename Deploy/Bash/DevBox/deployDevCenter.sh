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
  local galleryName="$6"

  # Download Dev Center template file
  devCenterTemplateFile="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/devCenter-template.json"
  echo "Downloading Dev Center template from ${devCenterTemplateFile}..."
  wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${devCenterTemplateFile}" -O "${outputFile}"
  echo "Successfully downloaded the image template to ${outputFile}."

  # Replace placeholders in the downloaded template
  echo "Updating placeholders in the template..."
  sed -i "s/<devCenterName>/$devCenterName/g" "$outputFile"
  sed -i "s/<location>/$location/g" "$outputFile"
  sed -i "s/<subscriptionId>/$subscriptionId/g" "$outputFile"
  sed -i "s/<resourceGroupName>/$resourceGroupName/g" "$outputFile"
  sed -i "s/<identityName>/$identityName/g" "$outputFile"
  sed -i "s/<galleryName>/$galleryName/g" "$outputFile"

  echo "Creating Azure Dev Center: $devCenterName..."

  az deployment group create \
    --resource-group "$resourceGroupName" \
    --template-file "$outputFile" 

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
if [[ $# -lt 6 ]]; then
  usage
  exit 1
fi

# Call the create_dev_center function with the provided arguments.
create_dev_center "$@"
