# Azure Shared Image Gallery Deployment Script

This Bash script facilitates the creation of a shared image gallery (SIG) in Microsoft Azure.

## Script Breakdown

### 1. Shebang and Error Handling

```bash
#!/bin/bash

# Exit on any non-zero command to ensure the script stops if there's a problem
set -e
```

This indicates that the script should be executed using the `bash` shell. The `set -e` causes the script to exit immediately if a command exits with a non-zero status.

### 2. Usage Function

```bash
usage() {
    echo "Usage: $0 <galleryName> <location> <galleryResourceGroup>"
    echo "Example: $0 myGallery eastus myResourceGroup"
    exit 1
}
```

The function `usage` provides instructions on how to use the script if it's invoked incorrectly.

### 3. Argument Validation

```bash
# Check for correct number of arguments
if [[ "$#" -ne 3 ]]; then
    echo "Error: Incorrect number of arguments provided."
    usage
fi
```

The script expects exactly three arguments. If not provided, it informs the user about the error.

### 4. Variable Assignment

```bash
galleryName="$1"
location="$2"
galleryResourceGroup="$3"
```

The script assigns the three expected arguments to more descriptive variable names.

### 5. Display Information

```bash
echo "----------------------------------------------"
echo "Gallery Name: $galleryName"
echo "Location: $location"
echo "Resource Group: $galleryResourceGroup"
echo "----------------------------------------------"
echo "Creating resource in Azure with the provided details..."
```

This section uses the `echo` commands to display information to the user.

### 6. Azure CLI Command

```bash
az sig create \
    --gallery-name "$galleryName" \
    --resource-group "$galleryResourceGroup" \
    --location "$location" \
    --tags  "division=Contoso-Platform" \
            "Environment=DevWorkstationService-Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=eShopOnContainers" 
```

This command does the main job of the script by calling the Azure CLI to create a shared image gallery.

### 7. Completion Notification

```bash
echo "----------------------------------------------"
echo "Operation completed successfully!"
```

Once the Azure CLI command completes without errors, this message notifies the user.

## Requirements

- [Azure CLI installation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Proper authentication to an Azure subscription using the [Azure CLI's authentication mechanism](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)

## Usage

To use this script, provide it with three parameters:

1. Name of the gallery
2. Its location
3. The resource group where it should be created
