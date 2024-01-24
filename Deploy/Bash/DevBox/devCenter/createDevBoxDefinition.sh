#!/bin/bash

# Check if all required arguments are provided
if [[ $# -lt 7 ]]; then
    echo "Usage: $0 <subscriptionId> <location> <devBoxResourceGroupName> <devCenterName> <galleryName> <imageName> <networkConnectionName>"
    exit 1
fi

# Assign input arguments to camelCase variables
subscriptionId="$1"
location="$2"
devBoxResourceGroupName="$3"
devCenterName="$4"
galleryName="$5"
imageName="$6"
networkConnectionName="$7"

# Function to create development pools and boxes
createDevPoolsAndDevBoxes() {
    local location="$1"
    local devBoxDefinitionName="$2"
    local networkConnectionName="$3"
    local poolName="$4"
    local devBoxResourceGroupName="$5"
    local devBoxName="$6"
    local devCenterName="$7"

    declare -A projects=(
        ["eShop"]="eShop"
        ["Contoso"]="Contoso"
        ["Fabrikam"]="Fabrikam"
        ["Tailwind"]="Tailwind"
    )

    for projectName in "${!projects[@]}"; do
        # Creating DevBox Pools
        echo "Creating DevBox Pools for $projectName..."
        ./devBox/devCenter/createDevBoxPools.sh "$location" "$devBoxDefinitionName" "$networkConnectionName" "$poolName" "$projectName" "$devBoxResourceGroupName"
        echo "DevBox Pools for $projectName created successfully."
    done
}

# Inform the user about the initialization step
echo "Initializing script with:
subscriptionId: $subscriptionId
location: $location
devBoxResourceGroupName: $devBoxResourceGroupName
devCenterName: $devCenterName
galleryName: $galleryName
imageName: $imageName."

# Construct necessary variables
imageReferenceId="/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/${galleryName}/images/${imageName}/versions/1.0.0"
devBoxDefinitionName="devBox-$imageName"
poolName="$imageName-pool"
devBoxName="$imageName-devbox"

# Display constructed variables
echo "Constructed variables:
imageReferenceId: $imageReferenceId
devBoxDefinitionName: $devBoxDefinitionName
networkConnectionName: $networkConnectionName
poolName: $poolName
devBoxName: $devBoxName
imageName: $imageName"

# Create a DevBox definition
echo "Creating DevBox definition..."
az devcenter admin devbox-definition create --location "$location" \
    --image-reference id="$imageReferenceId" \
    --os-storage-type "ssd_256gb" \
    --sku name="general_i_8c32gb256ssd_v2" \
    --name "$devBoxDefinitionName" \
    --dev-center-name "$devCenterName" \
    --resource-group "$devBoxResourceGroupName"

echo "DevBox definition created successfully."

# Invoke the function to create development pools and boxes
createDevPoolsAndDevBoxes "$location" "$devBoxDefinitionName" "$networkConnectionName" "$poolName" "$devBoxResourceGroupName" "$devBoxName" "$devCenterName"
