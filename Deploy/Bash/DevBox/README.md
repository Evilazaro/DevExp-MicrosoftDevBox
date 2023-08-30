# **Microsoft Dev Box Deployment Script*

This Bash script facilitates the automated creation of Azure resources such as a Resource Group, Virtual Network (VNet), and sets up a network connection for the Azure Development Center with domain-join capabilities. It's essential for users or developers aiming to quickly deploy a standardized environment in Azure for development or testing.

## **Table of Contents**

- [Script Flow](#script-flow)
- [Usage](#usage)
  - [Arguments](#arguments)
  - [Example](#example)
- [Notes](#notes)
- [Troubleshooting](#troubleshooting)

## **Script Flow**

1. **Display the planned actions**:
    - The script first showcases the set actions by rendering the values of the planned Azure resources (e.g., Subscription ID, Resource Group name, VNet name, etc.)

2. **Check argument count**:
    - It checks to ensure three arguments are provided: SUBSCRIPTION_ID, LOCATION, and IMAGE_RESOURCE_GROUP_NAME. If not, an error message will be displayed.

3. **Assign arguments to variables**:
    - Assigns the provided arguments to their respective variables.

4. **Resource Group Creation**:
    - Uses the Azure CLI to create a Resource Group with certain tags.

5. **Virtual Network and Subnet Creation**:
    - Attempts to create a Virtual Network (VNet) and Subnet within the newly created Resource Group.

6. **Setup Network Connection**:
    - Aims to establish a network connection for the Azure Development Center post successful VNet and Subnet creation.

7. **Completion Message**:
    - On successful execution of all steps, a completion message is displayed.

## **Usage**

Navigate to the script's directory and run:

```bash
./[script_name].sh [SUBSCRIPTION_ID] [LOCATION] [IMAGE_RESOURCE_GROUP_NAME]
```

## Arguments

- **SUBSCRIPTION_ID**: The Azure subscription ID.
- **LOCATION**: Azure location (region), e.g., "eastus".
- **IMAGE_RESOURCE_GROUP_NAME**: Name of the resource group.

## Example

```bash
./deployDevBox.sh "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" "eastus" "MyResourceGroup"
```
## Notes

- Ensure the `az` Azure CLI tool is installed and authenticated.
- The script calls two more scripts inside the `./Vnet` directory. Ensure they're present and have execution permissions.
- Always review and understand scripts before execution, especially when making changes to cloud resources.

## Troubleshooting

- The script provides error messages corresponding to failed steps. Ensure correct argument values and required Azure permissions.
- Ensure `./Vnet/deployVnet.sh` and `./Vnet/createNetWorkConnection.sh` are executable. If not, run:

```bash
chmod +x ./Vnet/deployVnet.sh ./Vnet/createNetWorkConnection.sh
```

