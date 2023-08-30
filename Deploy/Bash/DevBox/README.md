# Microsoft Dev Box Deployment Script

This Bash script is designed to automate the creation of an Azure Resource Group, a Virtual Network (VNet) inside that Resource Group, and to set up a network connection for Azure Development Center with domain-join capabilities.

## Script Overview

1. **Display Information**: Before performing any actions, the script will display a summary of the planned actions. This ensures that the user can review the details before the actual operations commence.
2. **Argument Check**: The script expects exactly 5 arguments. If the number of arguments is not 5, it will display an error message and provide a usage guide.
3. **Azure Resource Group Creation**: The script will create a new Azure Resource Group with specified tags.
4. **Virtual Network and Subnet Creation**: A Virtual Network and Subnet will be created by invoking a separate shell script (`deployVnet.sh`).
5. **Network Connection Setup**: The script will set up a network connection for Azure Development Center using another shell script (`createNetWorkConnection.sh`).

## Function Details

### `display_info()`

Displays the following details:

- Subscription ID
- Resource Group
- Location
- VNet Name
- Subnet Name

### `main()`

This is the main execution function. It performs the following steps:

1. Check if the correct number of arguments has been provided.
2. Display planned actions for clarity.
3. Create the Azure Resource Group.
4. Create the Virtual Network and Subnet.
5. Set up a network connection for the Azure Development Center.

## Usage

```bash
./deployDevBox.sh [SUBSCRIPTION_ID] [LOCATION] [FRONT_END_IMAGE_NAME] [BACK_END_IMAGE_NAME] [IMAGE_RESOURCE_GROUP_NAME]
