# Microsoft DevBox Environment Creation Demo

## Introduction

This demo guides you through the setup process of a Microsoft DevBox environment. By the end of this tutorial, you'll have a fully operational DevBox environment, primed for development and testing.

## Prerequisites

- A Microsoft account.
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
- Familiarity with Azure services.

## Table of Contents

- [Setting Up Azure Resources](#setting-up-azure-resources)
- [Understanding the deploy.sh Bash Script](#understanding-the-deploysh-bash-script)
- [Next Steps and Additional Resources](#next-steps-and-additional-resources)

## Setting Up Azure Resources

Before deploying DevBox, ensure Azure resources are properly configured:

1. **Navigate to the Deploy folder**:
    ```bash
    cd Deploy\
    ```

2. **Execute the deploy.sh bash script, providing the Azure Subscription Name as an argument**:
    ```bash
    ./deploy.sh <subscription-name>
    ```

## Understanding the deploy.sh Bash Script

The Bash script streamlines operations associated with resource group setups and image creations on Azure. Here's a detailed breakdown:

### Overview

- Authenticate into Azure.
- Establish an Azure resource group.
- Generate images via templates for front-end and back-end engineering configurations.
- Deploy a Microsoft DevBox.

### Breakdown

1. **Azure Login**

    ```bash
    echo "Logging into Azure..."
    ./login.sh $1
    ```

    This segment starts by printing "Logging into Azure..." and then launches the `login.sh` script, providing the `$1` argument.

2. **Initialize Variables**

    Variables are initialized for the process. These variables include the resource group's name, the Azure deployment region, the identity associated with the image builder, and the Azure subscription ID.

3. **Resource Group Creation**

    ```bash
    az group create -n $imageResourceGroup -l $location
    ```

    The Azure CLI `az group create` command establishes a new resource group.

4. **Managed Identity Creation**

    ```bash
    az identity create --resource-group $imageResourceGroup -n $identityName
    ```

    This step crafts a managed identity inside the previously generated resource group.

5. **Register Azure Features**

    ```bash
    ./registerFeatures.sh
    ```

    The `registerFeatures.sh` script handles the Azure features registration essential for image creation.

6. **User-Assigned Managed Identity Creation**

    ```bash
    ./createUserAssignedManagedIdentity.sh $imageResourceGroup $subscriptionID $identityId
    ```

    A script is launched to shape a user-assigned managed identity.

7. **Front-end and Back-end Image Creation**

    The image creation process is prepped and initiated for both engineering configurations.

8. **VM Images Creation and Build**

    ```bash
    ./Deploy-DevBox.sh $subscriptionID $imageResourceGroup $location $imageName $identityName
    ```

    Lastly, the Microsoft DevBox is deployed using the `Deploy-DevBox.sh` script.

## Conclusion

Using the script automates several Azure-related tasks, ensuring a consistent setup, time-saving, and minimized deployment errors.

## Next Steps and Additional Resources

### Microsoft Build

- **Develop in the cloud with Microsoft Dev Box | BRK251H**

    [![Watch the video](https://img.youtube.com/vi/mD225hXs63s/maxresdefault.jpg)](https://youtu.be/mD225hXs63s)

### Microsoft Docs

- [What is Microsoft Dev Box?](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
- Dive deeper into [Microsoft Docs](https://learn.microsoft.com/en-us/azure/dev-box/)
- Quick Starts: [Configure Microsoft DevBox](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service?tabs=AzureADJoin).

---

© 2023 [Your Name or Organization]. All rights reserved.
