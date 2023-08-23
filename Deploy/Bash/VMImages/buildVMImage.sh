#!/bin/bash
set -e  # Exit the script if any command fails

# Assign command line arguments to variables
outputFile="$1"
subscriptionID="$2"
galleryResourceGroup="$3"
location="$4"
imageName="$5"
identityName="$6"
imageTemplateFile="$7"
galleryName="ContosoImageGallery"

# Inform the user about the initiation of the image template download process
echo "Starting the process..."
echo "Deploying Compute Gallery ${galleryName}..."

././ComputeGallery/deployComputeGallery.sh $galleryName $location $galleryResourceGroup

echo "Attempting to download image template from ${imageTemplateFile}..."

# Use 'weget' to fetch the image template and save it to the specified location
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache"  $imageTemplateFile -O $outputFile

# Indicate the file download completion to the user
echo "Successfully downloaded the image template. Saved to ${outputFile}."

# Substitute placeholders in the template file with the provided variable values
echo "Substituting placeholders in the template with provided details..."

sed -i -e "s%<subscriptionID>%$subscriptionID%g" "$outputFile"
sed -i -e "s%<rgName>%$galleryResourceGroup%g" "$outputFile"
sed -i -e "s%<region>%$location%g" "$outputFile"
sed -i -e "s%<location>%$location%g" "$outputFile"
sed -i -e "s%<imageName>%$imageName%g" "$outputFile"
sed -i -e "s%<identityName>%$identityName%g" "$outputFile"
sed -i -e "s%<sharedImageGalName>%$galleryName%g" "$outputFile"

echo "Template placeholders successfully updated with the provided details."

# Create the image resource using the modified template
echo "Attempting to create image resource '${imageName}' in Azure..."

az deployment group create \
    --name $imageName \
    --template-file "$outputFile" \
    --resource-group "$galleryResourceGroup" \
    --parameters apiVersion="2020-02-14" imageTemplateName=$imageName svclocation=$location

# Inform the user about the build initiation process
echo "Initiating the build process for Image '${imageName}' in Azure..."

# Start the image build process

az resource invoke-action \
    --name $imageName \
    --resource-group $galleryResourceGroup \
    --action "Run" \
    --resource-type "Microsoft.VirtualMachineImages/imageTemplates" \
    --request-body '{}' \
    --query id \
    --api-version "2020-02-14"


echo "Build process for Image '${imageName}' has been successfully initiated!"
