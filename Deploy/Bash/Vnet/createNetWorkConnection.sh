#!/usr/bin/env bash

# Variables
templateUrl='https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Network-Connection-Template.json'
outputFilePath='./DownloadedTempTemplates/Network-Connection-Template-Output.json'

# Check if the correct number of arguments is provided.
if [[ "$#" -ne 5 ]]; then
    printf "Error: Incorrect number of arguments.\n"
    printf "Usage: %s <location> <subscriptionId> <resourceGroupName> <vnetName> <subNetName>\n" "$0"
    exit 1
fi

# Assign command-line arguments to variables with descriptive names.
location="$1"
subscriptionId="$2"
resourceGroupName="$3"
vnetName="$4"
subNetName="$5"

# Download the ARM template from the URL to the specified file path.
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "$templateUrl" -O "$outputFilePath"

# Replace placeholders with provided arguments in the template file.
sed -i -e "s%<location>%$location%g" \
       -e "s%<subscriptionId>%$subscriptionId%g" \
       -e "s%<resourceGroupName>%$resourceGroupName%g" \
       -e "s%<vnetName>%$vnetName%g" \
       -e "s%<subNetName>%$subNetName%g" "$outputFilePath"

# Provide feedback to the user about the deployment initiation.
printf "Initiating deployment using the ARM Template...\n"

# Deploy the ARM Template using the Azure CLI.
if az deployment group create \
    --name Network-Connection-Template \
    --template-file "$outputFilePath" \
    --resource-group "$resourceGroupName"; then
    printf "Deployment was successful!\n"
else
    printf "Deployment failed. Please check the provided parameters and try again.\n"
    exit 2
fi
