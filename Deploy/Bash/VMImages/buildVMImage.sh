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

imageDefinitionTemplateFile="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/VM-Image-Definition-Template.json"
imageDefinitionOutputFile="./DownloadedTempTemplates//VM-Image-Definition-Template-Output.json"

# Fetch the image template and save it to the specified location
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${imageDefinitionTemplateFile}" -O "${imageDefinitionOutputFile}"

# Function to substitute placeholders in files
substitute_placeholders() {
  local file="$1"
  shift  # shift arguments to the left, so $2 becomes $1, $3 becomes $2, etc.
  local args=("$@")  # all remaining arguments are our substitutions

  for ((i=0; i<${#args[@]}; i+=2)); do
    sed -i -e "s%${args[$i]}%${args[$i+1]}%g" "${file}"
  done
}

# Substitute placeholders for the Image Definition
substitute_placeholders "${imageDefinitionOutputFile}" \
  "<location>" "${location}" \
  "<imageName>" "${imageName}" \
  "<offer>" "${offer}" \
  "<galleryName>" "${galleryName}" \
  "<sku>" "${sku}" \
  "<publisher>" "${publisher}"

az deployment group create \
    --name "${imageName}" \
    --template-file "${imageDefinitionOutputFile}" \
    --resource-group "${galleryResourceGroup}"

echo "Attempting to download image template from ${imageTemplateFile}..."
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${imageTemplateFile}" -O "${outputFile}"
echo "Successfully downloaded the image template. Saved to ${outputFile}."

echo "Substituting placeholders in the template with provided details..."
# Substitute placeholders for the main Image Template
substitute_placeholders "${outputFile}" \
  "<subscriptionID>" "${subscriptionID}" \
  "<rgName>" "${galleryResourceGroup}" \
  "<region>" "${location}" \
  "<location>" "${location}" \
  "<imageName>" "${imageName}" \
  "<identityName>" "${identityName}" \
  "<sharedImageGalName>" "${galleryName}" \
  "<offer>" "${offer}" \
  "<sku>" "${sku}" \
  "<publisher>" "${publisher}"

echo "Template placeholders successfully updated with the provided details."

echo "Attempting to create image resource '${imageName}' in Azure..."
az deployment group create \
    --name "${imageName}" \
    --template-file "${outputFile}" \
    --resource-group "${galleryResourceGroup}" 
echo "Successfully created image resource '${imageName}' in Azure."

echo "Initiating the build process for Image '${imageName}' in Azure..."
az resource invoke-action \
    --name "${imageName}" \
    --resource-group "${galleryResourceGroup}" \
    --action "Run" \
    --resource-type "Microsoft.VirtualMachineImages/imageTemplates" \
    --request-body '{}' \
    --query id \
    --api-version "2020-02-14"


echo "Build process for Image '${imageName}' has been successfully initiated!"
