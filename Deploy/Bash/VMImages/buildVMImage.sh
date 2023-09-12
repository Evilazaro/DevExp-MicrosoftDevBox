#!/usr/bin/env bash

# Exit script immediately on any errors
set -e  

# Ensure that the necessary number of arguments are provided
if [ "$#" -ne 11 ]; then
  echo "Usage: $0 outputFile subscriptionID resourceGroupName location imageName identityName imageTemplateFile galleryName offer sku publisher"
  exit 1
fi

# Check for the necessary tools: wget, az, and sed
echo "Checking for the necessary tools..."
for tool in wget az sed; do
  if ! command -v ${tool} &> /dev/null; then
    echo "Error: ${tool} is required but not installed. Exiting."
    exit 1
  fi
done

# Assign command-line arguments to variables
outputFile="$1"
subscriptionID="$2"
resourceGroupName="$3"
location="$4"
imageName="$5"
identityName="$6"
imageTemplateFile="$7"
galleryName="$8"
offer="$9"
sku="${10}"
publisher="${11}"

# Starting the process to create image definitions
echo "Initiating the process to create image definitions..."

# Construct image definition name and feature list
imageDefName="${imageName}-image-def"
features="SecurityType=TrustedLaunch IsHibernateSupported=true"

# Creating image definition using az cli
echo "Creating image definition..."
az sig image-definition create \
    --resource-group ${resourceGroupName} \
    --gallery-name ${galleryName} \
    --gallery-image-definition ${imageDefName} \
    --os-type Windows \
    --publisher ${publisher} \
    --offer ${offer} \
    --sku ${sku} \
    --os-state generalized \
    --hyper-v-generation V2 \
    --features "${features}" \
    --location ${location} \
    --tags  "division=Contoso-Platform" \
            "Environment=DevWorkstationService-Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=eShopOnContainers"

# Download the image template file
echo "Downloading image template from ${imageTemplateFile}..."
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${imageTemplateFile}" -O "${outputFile}"
echo "Image template successfully downloaded to ${outputFile}."

# Replacing placeholders in the downloaded template with actual values
echo "Updating placeholders in the template..."
sed -i "s/<subscriptionID>/${subscriptionID}/g" "${outputFile}"
sed -i "s/<rgName>/${resourceGroupName}/g" "${outputFile}"
sed -i "s/<imageName>/${imageName}/g" "${outputFile}"
sed -i "s/<imageDefName>/${imageDefName}/g" "${outputFile}"
sed -i "s/<sharedImageGalName>/${galleryName}/g" "${outputFile}"
sed -i "s/<location>/${location}/g" "${outputFile}"
sed -i "s/<identityName>/${identityName}/g" "${outputFile}"
echo "Template placeholders successfully updated."

# Deploy resources in Azure using the updated template
echo "Creating image resource '${imageName}' in Azure..."
az deployment group create \
    --resource-group ${resourceGroupName} \
    --template-file ${outputFile} 

echo "Image resource '${imageName}' successfully created in Azure."

# Initiate the build process for the image in Azure
echo "Initiating the build process for image '${imageName}' in Azure..."
az resource invoke-action \
    --ids $(az resource show --name ${imageName} --resource-group ${resourceGroupName} --resource-type "Microsoft.VirtualMachineImages/imageTemplates" --query id --output tsv) \
    --action "Run" \
    --request-body '{}' \
    --query properties.outputs
    
echo "Build process for image '${imageName}' successfully initiated in Azure."
