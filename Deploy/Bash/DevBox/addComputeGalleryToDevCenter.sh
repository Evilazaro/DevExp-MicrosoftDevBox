#!/usr/bin/env bash

# Check if the required number of arguments are passed
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <Subscription ID> <Resource Group Name> <Dev Center Name> <Gallery Name>"
  exit 1
fi

# Assign command line arguments to variables with descriptive names
subscriptionId="$1"
resourceGroupName="$2"
devCenterName="$3"
galleryName="$4"

# Construct the gallery resource ID
galleryResourceId="/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/galleries/$galleryName"

# Echo the information about the operation to be performed
echo "Creating a gallery in Azure Dev Center..."
echo "Subscription ID: $subscriptionId"
echo "Resource Group Name: $resourceGroupName"
echo "Dev Center Name: $devCenterName"
echo "Gallery Name: $galleryName"

# Create the gallery using the az devcenter admin gallery create command
az devcenter admin gallery create \
    --gallery-resource-id "$galleryResourceId" \
    --dev-center-name "$devCenterName" \
    --name "$galleryName" \
    --resource-group "$resourceGroupName"

# Check the exit status of the last command and echo an appropriate message
if [ "$?" -eq 0 ]; then
  echo "Gallery creation successful."
else
  echo "Gallery creation failed."
fi
