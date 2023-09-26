#!/bin/bash

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
imgSKU="${10}"
publisher="${11}"
identityResourceGroupName="${12}"

imageDefName="${imageName}-def"
features="SecurityType=TrustedLaunch IsHibernateSupported=true"

az sig image-definition create \
    --resource-group ${resourceGroupName} \
    --gallery-name ${galleryName} \
    --gallery-image-definition ${imageDefName} \
    --os-type Windows \
    --publisher ${publisher} \
    --offer ${offer} \
    --sku ${imgSKU} \
    --os-state generalized \
    --hyper-v-generation V2 \
    --features "${features}" \
    --location ${location} \
    --tags  "division=Contoso-Platform" \
            "Environment=Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "division=Contoso-Platform" \
            "solution=eShop" \
            "businessUnit=e-Commerce"

# Download the image template file
echo "Downloading image template from ${imageTemplateFile}..."
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "${imageTemplateFile}" -O "${outputFile}"
echo "Image template successfully downloaded to ${outputFile}."

# Replacing placeholders in the downloaded template with actual values
echo "Updating placeholders in the template..."
sed -i "s/<subscriptionID>/${subscriptionID}/g" "${outputFile}"
sed -i "s/<rgName>/${resourceGroupName}/g" "${outputFile}"
sed -i "s/<rgIdentity>/${identityResourceGroupName}/g" "${outputFile}"
sed -i "s/<imageName>/${imageName}/g" "${outputFile}"
sed -i "s/<imageDefName>/${imageDefName}/g" "${outputFile}"
sed -i "s/<sharedImageGalName>/${galleryName}/g" "${outputFile}"
sed -i "s/<location>/${location}/g" "${outputFile}"
sed -i "s/<identityName>/${identityName}/g" "${outputFile}"
echo "Template placeholders successfully updated."

az deployment group create \
    --resource-group ${resourceGroupName} \
    --template-file ${outputFile} 

az resource invoke-action \
    --ids $(az resource show --name ${imageName} --resource-group ${resourceGroupName} --resource-type "Microsoft.VirtualMachineImages/imageTemplates" --query id --output tsv) \
    --action "Run" \
    --request-body '{}' \
    --query properties.outputs
    

