# Azure Compute Gallery Script Deployment

This is a Bash script designed to simplify the process of creating a resource in Azure. The script accepts three arguments representing the gallery name, location, and resource group. By leveraging Azure CLI's `az sig create` command, this script creates a resource in Azure with the provided details.

## Pre-requisites

1. **Azure CLI**: Ensure you have the Azure CLI installed and properly configured.
2. **Authentication**: Make sure you're authenticated to the right Azure account (where you intend to create the resources).

## Script Flow

1. **Error Handling**: The script first checks if any command returns a non-zero value (indicative of an error). If such an occurrence is detected, the script will terminate immediately.
2. **Usage Function**: A function (`usage`) is defined which displays how to use the script correctly.
3. **Argument Check**: The script checks if the number of arguments provided by the user is exactly 3. If not, an error is displayed and the script exits.
4. **Assigning Arguments**: The three arguments are assigned to descriptive variable names for better readability.
5. **Display Details**: The provided details are displayed back to the user.
6. **Azure CLI Command Execution**: The Azure CLI command (`az sig create`) is executed to create the resource in Azure with the given details and additional pre-defined tags.
7. **Completion Notification**: Upon successful completion, the user is notified that the operation was successful.

## Usage

To use the script, make sure to provide the necessary three arguments in the following order:

1. `galleryName`: The name of the gallery.
2. `location`: The Azure location (e.g., eastus, westus, etc.).
3. `galleryResourceGroup`: The name of the resource group.

```bash
./deployComputeGallery.sh <galleryName> <location> <galleryResourceGroup>
````

## Output

```bash
----------------------------------------------
Gallery Name: [provided gallery name]
Location: [provided location]
Resource Group: [provided resource group]
----------------------------------------------
Creating resource in Azure with the provided details...
```