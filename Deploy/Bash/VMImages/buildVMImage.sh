#!/bin/bash

set -e  # Exit the script if any command fails

# Check if necessary tools are available
for tool in wget az sed; do
  command -v ${tool} > /dev/null 2>&1 || { echo "${tool} is required but not installed. Exiting."; exit 1; }
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

echo "Attempting to create the Image Definitions"
imageDefName="${imageName}-image-def"

# Create Image Definition
# Create the image definition
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
    --features "SecurityType=TrustedLaunch" \
    --location $location

echo "Attempting to download image template from ${imageTemplateFile}..."
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${imageTemplateFile}" -O "${outputFile}"
echo "Successfully downloaded the image template. Saved to ${outputFile}."

echo "Substituting placeholders in the template with provided details..."
# Substitute placeholders for the main Image Template
# Perform replacements
sed -i "s/<subscriptionID>/$subscriptionID/g" "$outputFile"
sed -i "s/<rgName>/$galleryResourceGroup/g" "$outputFile"
sed -i "s/<runOutputName>/$imageName/g" "$outputFile"
sed -i "s/<imageDefName>/$imageDefName/g" "$outputFile"
sed -i "s/<sharedImageGalName>/$galleryName/g" "$outputFile"
sed -i "s/<region1>/$location/g" "$outputFile"
sed -i "s/<region2>/$replRegion2/g" "$outputFile"
sed -i "s/<imgBuilderId>/$identityNameResourceId/g" "$outputFile"


echo "Template placeholders successfully updated with the provided details."

echo "Attempting to create image resource '${imageName}' in Azure..."
# Deploy resources
az deployment group create \
    --resource-group $galleryResourceGroup \
    --template-file $outputFile 
    
echo "Successfully created image resource '${imageName}' in Azure."

echo "Initiating the build process for Image '${imageName}' in Azure..."
az resource invoke-action \
    --ids $(az resource show --name $imageName --resource-group $galleryResourceGroup --resource-type "Microsoft.VirtualMachineImages/imageTemplates" --query id --output tsv) \
    --action "Run" \
    --request-body '{}' \
    --query properties.outputs


echo "Build process for Image '${imageName}' has been successfully initiated!"
