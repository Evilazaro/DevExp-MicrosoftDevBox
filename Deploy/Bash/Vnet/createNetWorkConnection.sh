#!/bin/bash

# Script for deploying an Azure Resource Manager (ARM) template.

# --- Variables ---
TEMPLATE_URL='https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Network-Connection-Template.json'
OUTPUT_FILE_PATH='./DownloadedTempTemplates/Network-Connection-Template-Output.json'

# --- Functions ---
# Print usage information
print_usage() {
    echo "Usage: $0 <location> <subscriptionId> <resourceGroupName> <vnetName> <subNetName>"
}

# --- Main ---

# Ensure the correct number of arguments is provided.
if [[ "$#" -ne 5 ]]; then
    echo "Error: Incorrect number of arguments provided."
    print_usage
    exit 1
fi

# Assign command-line arguments to descriptive variables.
LOCATION="$1"
SUBSCRIPTION_ID="$2"
RESOURCE_GROUP_NAME="$3"
VNET_NAME="$4"
SUBNET_NAME="$5"

# Download the ARM template from the URL to the specified path.
echo "Downloading the ARM template..."
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "$TEMPLATE_URL" -O "$OUTPUT_FILE_PATH"

# Check if the download was successful
if [[ $? -ne 0 ]]; then
    echo "Error downloading the ARM template. Exiting."
    exit 2
fi

# Replace placeholders in the template file with provided arguments.
echo "Updating the ARM template with provided values..."
sed -i -e "s%<location>%$LOCATION%g" \
       -e "s%<subscriptionId>%$SUBSCRIPTION_ID%g" \
       -e "s%<resourceGroupName>%$RESOURCE_GROUP_NAME%g" \
       -e "s%<vnetName>%$VNET_NAME%g" \
       -e "s%<subNetName>%$SUBNET_NAME%g" "$OUTPUT_FILE_PATH"

# Start the deployment using the Azure CLI.
echo "Initiating deployment using the ARM Template..."
if az deployment group create \
    --name Network-Connection-Template \
    --template-file "$OUTPUT_FILE_PATH" \
    --resource-group "$RESOURCE_GROUP_NAME" \
     --tags  "division=Contoso-Platform" \
            "Environment=Dev-Workstation" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=eShopOnContainers"; then
    echo "Deployment was successful!"
else
    echo "Deployment failed. Please check the provided parameters and try again."
    exit 3
fi
