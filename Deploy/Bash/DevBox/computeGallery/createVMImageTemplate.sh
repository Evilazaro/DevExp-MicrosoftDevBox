#!/bin/bash

set -e

# Function to display usage instructions
displayUsage() {
    echo "Usage: $0 <outputFile> <subscriptionID> <resourceGroupName> <location> <imageName> <identityName> <imageFileUri> <galleryName> <offer> <imgSKU> <publisher> <identityResourceGroupName>"
    exit 1
}

# Parse and assign command-line arguments to variables
parseArguments() {
    if [[ $# -lt 12 ]]; then
        displayUsage
    fi

    outputFile="$1"
    subscriptionID="$2"
    resourceGroupName="$3"
    location="$4"
    imageName="$5"
    identityName="$6"
    imageFileUri="$7"
    galleryName="$8"
    offer="$9"
    imgSKU="${10}"
    publisher="${11}"
    identityResourceGroupName="${12}"
}

createImageDefinition() {
    local imageDefName="${imageName}Def"
    local features="SecurityType=TrustedLaunch IsHibernateSupported=true"

    echo "Creating image definition..."

    az sig image-definition create \
        --resource-group "${resourceGroupName}" \
        --gallery-name "${galleryName}" \
        --gallery-image-definition "${imageDefName}" \
        --os-type Windows \
        --publisher "${publisher}" \
        --offer "${offer}" \
        --sku "${imgSKU}" \
        --os-state generalized \
        --hyper-v-generation V2 \
        --features "${features}" \
        --location "${location}" \
        --tags  "division=Contoso-Platform" \
                "Environment=Prod" \
                "offer=Contoso-DevWorkstation-Service" \
                "Team=Engineering" \
                "solution=ContosoFabricDevWorkstation" \
                "businessUnit=e-Commerce"
}

retrieveImageGalleryID() {
    echo "Retrieving the ID of the image gallery..."

    imageGalleryId=$(az sig show --resource-group "${resourceGroupName}" \
                    --gallery-name "${galleryName}" --query id --output tsv)
}

retrieveUserAssignedID() {
    echo "Retrieving the ID of the user-assigned identity..."

    userAssignedId=$(az identity show --resource-group "${identityResourceGroupName}" \
                    --name "${identityName}" --query id --output tsv)
}

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

invokeActionOnResource() {
    echo "Invoking an action on the resource..."

    az resource invoke-action \
        --ids $(az resource show --name "${imageName}" --resource-group "${resourceGroupName}" --resource-type "Microsoft.VirtualMachineImages/imageTemplates" --query id --output tsv) \
        --action "Run" \
        --request-body '{}' \
        --query properties.outputs}

main() {
    parseArguments "$@"
    createImageDefinition
    retrieveImageGalleryID
    retrieveUserAssignedID
    createDeploymentGroup
    invokeActionOnResource
    echo "Script executed successfully."
}

main "$@"
