# Microsoft DevBox Environment Creation Demo

## Introduction

This demo walks you through the process of setting up a Microsoft DevBox environment. By the end of this tutorial, you'll have a fully functional DevBox environment ready for development and testing.

## Prerequisites

- A Microsoft account.
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
- Basic knowledge of Azure services.

## Table of Contents

1. [Setting Up Azure Resources](#setting-up-azure-resources)
2. [Understanding the deploy.sh Bash Script](#understanding-the-deploysh-bash-script)
5. [Next Steps and Additional Resources](#next-steps-and-additional-resources)

## Setting Up Azure Resources

Before installing DevBox, ensure that you have the necessary resources set up in Azure:

1. **Navigate to the Deploy folder**:
    ```bash
    cd Deploy\
    ```

2. **Run the deploy.sh bash script and inform the Azure Subscription Name as a parameter**:
    ```bash
    ./deploy.sh <subscription-name>
    ```

# Understanding the deploy.sh Bash Script 

This Bash script is designed to perform a series of operations related to setting up resource groups and creating images on Microsoft's Azure cloud platform. Let's break it down step by step.

## Overview

The script:

1. Logs into Azure.
2. Sets up an Azure resource group.
3. Creates images using given templates for both front-end and back-end engineer setups.
4. Deploys a Microsoft DevBox.

## Breakdown

### 1. Azure Login

```bash
# Initiating the Azure login process.
echo "Logging into Azure..."
./login.sh $1 `

```

Here, the script starts by printing "Logging into Azure..." and then runs another script named `login.sh`, passing an argument `$1`. This `login.sh` script is presumably used to authenticate to Azure.

### 2. Setting Initial Variables

Setting up initial variables for the process.

This section initializes some variables:

-   imageResourceGroup: The name of the resource group to be created.
-   location: Azure region where resources will be deployed.
-   identityName: Name for the identity associated with the image builder.
-   subscriptionID: Fetches the current user's Azure subscription ID.

### 3. Resource Group Creation

Creating the resource group in the defined location.
```bash
az group create -n $imageResourceGroup -l $location`
```

This uses Azure CLI's `az group create` command to create a new resource group with the specified name and location.

### 4. Managed Identity Creation

Creating a new managed identity within the resource group.
```bash
az identity create --resource-group $imageResourceGroup -n $identityName`
```

This step creates a managed identity within the previously created resource group. Managed identities provide Azure services with an automatically managed identity in Azure AD. You can use this identity to authenticate to any service that supports Azure AD authentication.

### 5. Register Azure Features


```bash
Registering necessary Azure features.
./Register-Features.sh`
```

This line runs another script, `Register-Features.sh`, which probably handles the registration of certain Azure features required for the image building process.

### 6. User-Assigned Managed Identity Creation

Creating a user-assigned managed identity.

```bash
./CreateUserAssignedManagedIdentity.sh $imageResourceGroup $subscriptionID $identityId`
```

This section runs a script to create a user-assigned managed identity, providing necessary details like resource group, subscription ID, and identity ID.

### 7. Front-end and Back-end Image Creation

These sections prepare and initiate the image creation process for both front-end and back-end engineers. For each, the steps are:

-   Set the image name.
-   Define the URL where the image template JSON file is located.
-   Specify the output file for the image creation process.
-   Call the `CreateImage.sh` script with the necessary parameters to initiate the image creation.

### 8. Create and build the VM images

```bash
# Create and build the VM images
./Deploy-DevBox.sh $subscriptionID $imageResourceGroup $location $imageName $identityName`
```

Lastly, the script deploys a Microsoft DevBox using the `Deploy-DevBox.sh` script. A DevBox is presumably a development environment, and the script sets it up using the provided parameters.

Conclusion
----------

The script is a structured way to automate several Azure operations related to image creation and deployment. By using such a script, a user can ensure a consistent setup process, save time on manual steps, and reduce the risk of errors in deployment.

## Next Steps and Additional Resources

### Microsoft Build
<iframe width="560" height="315" src="https://www.youtube.com/embed/mD225hXs63s" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>


- **Microsoft DevBox**: Check out [Microsoft Docs](https://learn.microsoft.com/en-us/azure/dev-box/)
- **DevBox Quick Starts**: Read [Configure Microsoft DevBox](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service?tabs=AzureADJoin).

---

© 2023 [Your Name or Organization]. All rights reserved.
