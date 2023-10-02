#!/bin/bash
# Best Practices Revised Bash Script

# Assigning input arguments to variables with more descriptive, camelCase names
subscriptionId="$1"      # subscription ID
location="$2"            # location
devBoxResourceGroupName="$3"   # resource group name
devCenterName="$4"       # development center name
galleryName="$5"         # gallery name
imageName="$6"           # image name
networkConnectionName="$7"     # network connection name

# Inform the user about the initialization step
echo "Initializing script with subscriptionId: $subscriptionId, location: $location, devBoxResourceGroupName: $devBoxResourceGroupName, devCenterName: $devCenterName, galleryName: $galleryName, and imageName: $imageName."

# Construct necessary variables with camelCase naming conventions
imageReferenceId="/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/${galleryName}/images/${imageName}Def/versions/1.0.0"
devBoxDefinitionName="devBox-$imageName"
projectName="eShop"
poolName="$imageName-pool"
devBoxName="$imageName-devbox"

# Echo the constructed variables
echo "Constructed variables:
imageReferenceId: $imageReferenceId
devBoxDefinitionName: $devBoxDefinitionName
networkConnectionName: $networkConnectionName
projectName: $projectName
poolName: $poolName
devBoxName: $devBoxName"

# Creating a DevBox definition with camelCase variable names and added echo for step tracking
echo "Creating DevBox definition..."
az devcenter admin devbox-definition create --location "$location" \
        --image-reference id="$imageReferenceId" \
        --os-storage-type "ssd_256gb" \
        --sku name="general_i_8c32gb256ssd_v2" \
        --name "$devBoxDefinitionName" \
        --dev-center-name "$devCenterName" \
        --resource-group "$devBoxResourceGroupName"

echo "DevBox definition created successfully."

# Creating DevBox Pools with added echo for step tracking
echo "Creating DevBox Pools..."
./devBox/devCenter/createDevBoxPools.sh "$location" "$devBoxDefinitionName" "$networkConnectionName" "$poolName" "$projectName" "$devBoxResourceGroupName"
echo "DevBox Pools created successfully."

# Creating DevBox for Engineers with added echo for step tracking
echo "Creating DevBox for Engineers..."
./devBox/devCenter/createDevBoxforEngineers.sh "$poolName" "$devBoxName" "$devCenterName" "$projectName"
echo "DevBox for Engineers created successfully."
