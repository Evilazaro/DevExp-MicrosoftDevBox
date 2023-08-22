#!/bin/bash
set -e  # Exit the script if any command fails

# Assign command line arguments to variables
outputFile="$1"
subscriptionID="$2"
imageResourceGroup="$3"
location="$4"
imageName="$5"
identityName="$6"
imageTemplateFile="$7"

# Inform the user about the initiation of the image template download process
echo "Starting the process..."
echo "Attempting to download image template from ${imageTemplateFile}..."

# Use 'curl' to fetch the image template and save it to the specified location
curl "$imageTemplateFile" -o "$outputFile"

# Indicate the file download completion to the user
echo "Successfully downloaded the image template. Saved to ${outputFile}."

# Substitute placeholders in the template file with the provided variable values
echo "Substituting placeholders in the template with provided details..."

sed -i -e "s%<subscriptionID>%$subscriptionID%g" "$outputFile"
sed -i -e "s%<rgName>%$imageResourceGroup%g" "$outputFile"
sed -i -e "s%<region>%$location%g" "$outputFile"
sed -i -e "s%<imageName>%$imageName%g" "$outputFile"
sed -i -e "s%<identityName>%$identityName%g" "$outputFile"

echo "Template placeholders successfully updated with the provided details."

# Create the image resource using the modified template
echo "Attempting to create image resource '${imageName}' in Azure..."

az resource create \
    --resource-group "$imageResourceGroup" \
    --properties @"$outputFile" \
    --is-full-object \
    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
    -n "$imageName"

# Inform the user about the build initiation process
echo "Initiating the build process for Image '${imageName}' in Azure..."

# Start the image build process
az resource invoke-action \
     --resource-group "$imageResourceGroup" \
     --resource-type  Microsoft.VirtualMachineImages/imageTemplates \
     -n "$imageName" \
     --action Run

echo "Build process for Image '${imageName}' has been successfully initiated!"
