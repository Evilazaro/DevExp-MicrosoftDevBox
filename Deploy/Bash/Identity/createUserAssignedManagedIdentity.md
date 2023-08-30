# Assign Role to a User-Assigned Managed Identity in Azure

This Bash script helps users assign a specific role to a User-Assigned Managed Identity within Azure.

## Table of Contents
- [Script Overview](#script-overview)
- [Script Flow](#script-flow)
- [Usage](#usage)
- [Example](#example)

## Script Overview

The script's primary purpose is to allow Azure administrators to grant an "Owner" role to a given User-Assigned Managed Identity on their Azure Subscription.

## Script Flow

1. **Constants Definition**: The script defines a constant `ROLE` which is set to "Owner".
2. **Usage Function (`usage`)**: This function, when invoked, displays the correct way to use the script.
3. **Argument Check Function (`check_args`)**: Checks the number of arguments passed to the script. If the number isn't three, an error message gets displayed, followed by the correct usage of the script.
4. **Header Printing Function (`print_header`)**: A utility function to print headers, making the output more readable.
5. **Role Assignment Function (`assign_role`)**: This function takes care of the actual role assignment. It uses the `az` (Azure CLI) command to grant a role to a specific identity for a specified Azure subscription.
6. **Main Execution**: The main logic of the script. First, it checks the provided arguments. Then, it prints out a descriptive header and displays the details of the given arguments. Ultimately, it uses the `assign_role` function to assign the role.

## Usage

To correctly use the script, it should be executed with the necessary arguments in the following format:

```bash
./script_name.sh <Resource Group> <Subscription ID> <Identity ID>
``````

**Where:**

- `<Resource Group>`: Represents the name of the Azure resource group.
- `<Subscription ID>`: Stands for the ID of your Azure subscription.
- `<Identity ID>`: Is the ID of the User-Assigned Managed Identity you wish to assign the role to.

**Note**: Before running this script, ensure the `az` (Azure CLI) tool is installed and authenticated on your system.

## Example

For instance, if your script is named `assignRole.sh`, you can use it as follows:
```bash
./assignRole.sh MyResourceGroup 12345678-9abc-def0-1234-56789abcdef0 11223344-5566-7788-99aa-bbccddeeff00
```


