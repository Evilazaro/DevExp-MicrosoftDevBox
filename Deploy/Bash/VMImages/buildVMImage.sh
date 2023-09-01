#!/bin/bash

set -e  # Exit the script if any command fails

echo "Checking necessary tools..."
# Check if necessary tools are available
for tool in wget az sed; do
  if ! command -v ${tool} &> /dev/null; then
    echo "${tool} is required but not installed. Exiting."
    exit 1
  fi
done

# Assign command line arguments to variables
outputFile="$1"
subscriptionID="$2"
galleryResourceGroup="$3"
location="$4"
imageName="$5"
identityName="$6"
imageTemplateFile="$7"
galleryName="$8"
offer="$9"
sku="${10}"
publisher="${11}"

echo "Starting the process to create Image Definitions..."
imageDefName="${imageName}-image-def"
features="SecurityType=TrustedLaunch IsHibernateSupported=true"

# Create Image Definition
echo "Creating image definition..."
az sig image-definition create \
    --resource-group $galleryResourceGroup \
    --gallery-name $galleryName \
    --gallery-image-definition $imageDefName \
    --os-type Windows \
    --publisher $publisher \
    --offer $offer \
    --sku $sku \
    --os-state generalized \
    --hyper-v-generation V2 \
    --features "$features" \
    --location $location \
    --tags  "division=Contoso-Platform" \
            "Environment=DevWorkstationService-Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=eShopOnContainers"

# Download image template
echo "Downloading image template from ${imageTemplateFile}..."
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${imageTemplateFile}" -O "${outputFile}"
echo "Successfully downloaded the image template to ${outputFile}."

# Replace placeholders in the downloaded template
echo "Updating placeholders in the template..."
sed -i "s/<subscriptionID>/$subscriptionID/g" "$outputFile"
sed -i "s/<rgName>/$galleryResourceGroup/g" "$outputFile"
sed -i "s/<imageName>/$imageName/g" "$outputFile"
sed -i "s/<imageDefName>/$imageDefName/g" "$outputFile"
sed -i "s/<sharedImageGalName>/$galleryName/g" "$outputFile"
sed -i "s/<location>/$location/g" "$outputFile"
sed -i "s/<identityName>/$identityName/g" "$outputFile"
echo "Template placeholders updated."

# Deploy resources in Azure
echo "Creating image resource '${imageName}' in Azure..."
az deployment group create \
    --resource-group $galleryResourceGroup \
    --template-file $outputFile 

echo "Successfully created image resource '${imageName}' in Azure."

# Initiate the build process for the image
echo "Starting the build process for Image '${imageName}' in Azure..."
az resource invoke-action \
    --ids $(az resource show --name $imageName --resource-group $galleryResourceGroup --resource-type "Microsoft.VirtualMachineImages/imageTemplates" --query id --output tsv) \
    --action "Run" \
    --request-body '{}' \
    --query properties.outputs
    
# Create image version
az sig image-version create \
    --resource-group $galleryResourceGroup \
    --gallery-name $galleryName \
    --gallery-image-definition $imageDefName \
    --gallery-image-version 1.0.0 \
    --target-regions $location \
    --managed-image "/subscriptions/$subscriptionID/resourceGroups/$galleryResourceGroup/providers/Microsoft.Compute/images/$imageName" \
    --replica-count 1 \
    --location $location \
    --target-regions "{ \"location\": \"$location\", \"replicaCount\": 1, \"storageAccountType\": \"Premium_LRS\" }" \
    --storage-account-type Premium_LRS \
     --tags  "division=Contoso-Platform" \
            "Environment=DevWorkstationService-Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=eShopOnContainers" 

echo "Build process for Image '${imageName}' has been initiated successfully!"
