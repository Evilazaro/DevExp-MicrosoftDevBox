#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

# Function to display usage instructions
displayUsage() {
    echo "Usage: $0 <outputFile> <subscriptionId> <resourceGroupName> <location> <imageName> <identityName> <imageFileUri> <galleryName> <offer> <imgSku> <publisher> <identityResourceGroupName>"
    exit 1
}

# Parse and assign command-line arguments to variables
parseArguments() {
    if [[ $# -lt 12 ]]; then
        displayUsage
    fi

    outputFile="$1"
    subscriptionId="$2"
    resourceGroupName="$3"
    location="$4"
    imageName="$5"
    identityName="$6"
    imageFileUri="$7"
    galleryName="$8"
    offer="$9"
    imgSku="${10}"
    publisher="${11}"
    identityResourceGroupName="${12}"
}

# Create an image definition in the Shared Image Gallery
createImageDefinition() {
    local imageDefName="${imageName}"
    local features="SecurityType=TrustedLaunch IsHibernateSupported=true"

    echo "Creating image definition..."

    az sig image-definition create \
        --resource-group "${resourceGroupName}" \
        --gallery-name "${galleryName}" \
        --gallery-image-definition "${imageDefName}" \
        --os-type Windows \
        --publisher "${publisher}" \
        --offer "${offer}" \
        --sku "${imgSku}" \
        --os-state generalized \
        --hyper-v-generation V2 \
        --features "${features}" \
        --location "${location}" \
        --tags  "division=petv2-Platform" \
                "Environment=Prod" \
                "offer=petv2-DevWorkstation-Service" \
                "Team=Engineering" \
                "solution=ContosoFabricDevWorkstation" \
                "businessUnit=e-Commerce"
}

# Retrieve the ID of the image gallery
retrieveImageGalleryId() {
    echo "Retrieving the ID of the image gallery..."

    imageGalleryId=$(az sig show --resource-group "${resourceGroupName}" \
                    --gallery-name "${galleryName}" --query id --output tsv)
    if [[ -z "$imageGalleryId" ]]; then
        echo "Error: Failed to retrieve the image gallery ID." >&2
        exit 1
    fi
}

# Retrieve the ID of the user-assigned identity
retrieveUserAssignedId() {
    echo "Retrieving the ID of the user-assigned identity..."

    userAssignedId=$(az identity show --resource-group "${identityResourceGroupName}" \
                    --name "${identityName}" --query id --output tsv)
    if [[ -z "$userAssignedId" ]]; then
        echo "Error: Failed to retrieve the user-assigned identity ID." >&2
        exit 1
    fi
}

# Create a deployment group
createDeploymentGroup() {
    echo "Creating a deployment group..."

    az deployment group create \
        --resource-group "${resourceGroupName}" \
        --template-uri "${imageFileUri}"  \
        --parameters imgName="${imageName}" \
                     imageGalleryId="${imageGalleryId}" \
                     userAssignedId="${userAssignedId}" \
                     location="${location}"
}

# Invoke an action on the resource
invokeActionOnResource() {
    echo "Invoking an action on the resource..."

    az resource invoke-action \
        --ids $(az resource show --name "${imageName}" --resource-group "${resourceGroupName}" --resource-type "Microsoft.VirtualMachineImages/imageTemplates" --query id --output tsv) \
        --action "Run"
}

# Main script execution starts here
createVMImageTemplate() {
    parseArguments "$@"
    createImageDefinition
    retrieveImageGalleryId
    retrieveUserAssignedId
    createDeploymentGroup
    invokeActionOnResource
    echo "Script executed successfully."
}

createVMImageTemplate "$@"