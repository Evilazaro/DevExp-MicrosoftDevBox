#!/bin/bash

# This script is designed to register various Azure Resource Providers necessary for managing and operating virtual machines, storage, networking, and other resources in Azure.

# Print a message indicating the start of the registration process.
echo "Registering Features"

# Register the Azure Resource Provider for Virtual Machine Images.
# This enables operations associated with Azure VM images, such as creating and managing custom images.
az provider register -n Microsoft.VirtualMachineImages

# Register the Azure Resource Provider for Compute.
# This enables operations related to Azure virtual machines and related compute resources.
az provider register -n Microsoft.Compute

# Register the Azure Resource Provider for Key Vault.
# This enables operations related to Azure Key Vault, which is used to manage secrets, encryption keys, and certificates.
az provider register -n Microsoft.KeyVault

# Register the Azure Resource Provider for Storage.
# This enables operations related to Azure Storage accounts, which offer cloud-based storage solutions.
az provider register -n Microsoft.Storage

# Register the Azure Resource Provider for Network.
# This enables operations related to Azure networking resources, such as Virtual Networks, Load Balancers, and more.
az provider register -n Microsoft.Network
