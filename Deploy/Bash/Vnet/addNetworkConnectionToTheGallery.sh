#!/usr/bin/env bash

# Ensure the script stops if any command fails.
set -e

# Function to print usage instructions.
print_usage() {
    echo "Usage: $0 <resourceGroup> <location> <vmName> <vnetName> <subnetName> <galleryName> <imageName>"
    echo "Creates a VM in Azure, stops, generalizes, captures it as an image, and shares it to a gallery."
}

# Ensure Azure CLI is installed.
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI (az) is not installed."
    exit 1
fi

# Ensure the required number of arguments are provided.
if [ "$#" -ne 7 ]; then
    print_usage
    exit 1
fi

# Gather input into named variables for clarity.
resourceGroup="${1}"
location="${2}"
vmName="${3}"
vnetName="${4}"
subnetName="${5}"
galleryName="${6}"
imageName="${7}"

# Echo the received inputs.
cat <<EOF
----------------------------------------
Starting operation with the following inputs:
Resource Group: ${resourceGroup}
Location:       ${location}
VM Name:        ${vmName}
VNET Name:      ${vnetName}
Subnet Name:    ${subnetName}
Gallery Name:   ${galleryName}
Image Name:     ${imageName}
----------------------------------------
EOF

# Create Virtual Network.
az network vnet create --name "${vnetName}" --resource-group "${resourceGroup}" --location "${location}" --subnet-name "${subnetName}"
echo "Virtual Network ${vnetName} created."

# Create a VM with a connection to the created Virtual Network.
az vm create --resource-group "${resourceGroup}" --name "${vmName}" --image UbuntuLTS --vnet-name "${vnetName}" --subnet "${subnetName}"
echo "VM ${vmName} created and connected to ${vnetName}."

# Stop the VM before generalizing.
az vm stop --resource-group "${resourceGroup}" --name "${vmName}"
echo "VM ${vmName} stopped."

# Generalize the VM.
az vm generalize --resource-group "${resourceGroup}" --name "${vmName}"
echo "VM ${vmName} generalized."

# Capture the VM to create an image.
az vm capture --resource-group "${resourceGroup}" --name "${vmName}" --vhd-name-prefix "${vmName}"
echo "Image captured from VM ${vmName}."

# Share the image to the gallery.
az sig image-version create --resource-group "${resourceGroup}" --gallery-name "${galleryName}" --gallery-image-definition "${imageName}" --gallery-image-version 1.0.0 --managed-image "/subscriptions/<your-subscription-id>/resourceGroups/${resourceGroup}/providers/Microsoft.Compute/images/${vmName}"
echo "VM image of ${vmName} shared to gallery ${galleryName}."

echo "Operation completed!"
