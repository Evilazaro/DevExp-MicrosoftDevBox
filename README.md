# Microsoft DevBox Demo for Contoso

Welcome to the Microsoft DevBox demo repository! This project aims to simulate a company named "Contoso" that leverages Microsoft DevBox for provisioning workstations to its engineers.

## Table of Contents

- [Description](#description)
- [Pre-Requisites](#pre-requisites)
- [Architecture](#architecture)
- [Projects](#projects)
- [How to Use the Scripts](#how-to-use-the-scripts)
- [Contributing](#contributing)
- [License](#license)

## Description

Contoso is a fictitious company utilizing Microsoft's DevBox to streamline the deployment of development environments. This repository offers a real-world simulation to demonstrate the capabilities of DevBox in a practical setting.

## Pre-Requisites

Before you delve into the project, ensure you have:

## 1. Environment
- This script should be executed within a Bash shell environment.

### Required Software:

#### All Environments:
- **Azure CLI**: The script uses the Azure Command-Line Interface (`az`) for many of its operations. Ensure that you have the Azure CLI installed and updated to the latest version. You can check its installation with `az --version`.
  - [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

#### For Windows:
- **Windows Subsystem for Linux (WSL)**: To run Bash scripts on Windows, it's recommended to use WSL. This provides a Linux-compatible kernel interface on Windows.
  - [Install WSL](https://docs.microsoft.com/en-us/windows/wsl/install)
- **Git Bash**: Another option for running Bash scripts on Windows is Git Bash.
  - [Download Git for Windows (includes Git Bash)](https://gitforwindows.org/)

#### For MacOS:
- **Terminal**: MacOS comes with a built-in terminal which supports Bash by default. No additional software is necessary to run Bash scripts. However, ensure that your MacOS version supports Bash. Starting from macOS Catalina, `zsh` is the default shell, but Bash can still be used.
- **Homebrew**: This is a package manager for MacOS, which can be handy to install additional software.
  - [Install Homebrew](https://brew.sh/)

### 2. Required Permissions:
- **Azure Subscription Access**: The user executing this script must have sufficient permissions on the target Azure subscription. This includes permissions for creating resource groups, deploying resources, and managing Azure AD identities. Typically, this might require an Azure role like 'Contributor' or 'Owner'. 
  - [Understand Azure RBAC roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview)

### 3. Cloning the repo


Bash
```sh

git clone https://github.com/Evilazaro/MicrosoftDevBox devBox

```
### 3.1 Required Directory Structure:
After cloning the repo, you will find the following Directory and Files structure. Ensure these scripts exist and are executable:
  
- [Login to Azure - File: ./Deploy/Bash/Identity/login.sh](./Deploy/Bash/Identity/login.md)
- [Managed Identity account creation - File: `./Deploy/Bash/Identity/createIdentity.sh`](./Deploy/Bash/Identity/createIdentity.sh)
- [Azure Features Registering - File: `./Deploy/Bash/Identity/registerFeatures.sh`](./Deploy/Bash/Identity/registerFeatures.sh)
- [text - File: `./Deploy/Bash/Identity/createUserAssignedManagedIdentity.sh`](./Deploy/Bash/Identity/createUserAssignedManagedIdentity.sh)
- [Vnet Deployment - File: `./Deploy/Bash/network/deployVnet.sh`](./Deploy/Bash/network/deployVnet.sh)
- [Networking Connection Deployment - File: `./Deploy/Bash/network/createNetWorkConnection.sh`](./Deploy/Bash/network/createNetWorkConnection.sh)
- [Compute Galery Deployment - File: `./Deploy/Bash/devBox/computeGallery/deployComputeGallery.sh`](./Deploy/Bash/devBox/computeGallery/deployComputeGallery.sh)
- [Dev Center Deployment - File: `./Deploy/Bash/devBox/devCenter/deployDevCenter.sh`](./Deploy/Bash/devBox/devCenter/deployDevCenter.sh)
- [Dev Center Projects Creation - File: `./Deploy/Bash/devBox/devCenter/createDevCenterProject.sh`](./Deploy/Bash/devBox/devCenter/createDevCenterProject.sh)
- [Custom VM Image Template deployment - File: `./Deploy/Bash/devBox/computeGallery/createVMImageTemplate.sh`](./Deploy/Bash/devBox/computeGallery/createVMImageTemplate.sh)
- [Dev Box Definition Creation - File: `./Deploy/Bash/devBox/devCenter/createDevBoxDefinition.sh`](./Deploy/Bash/devBox/devCenter/createDevBoxDefinition.sh)

### 5. Configuration:

In this section, we will explain the configuration part of the Bash script. This part of the script defines various variables and functions related to Azure resource management, identity, network, and image gallery.

### 5.1 Variables

The script starts by defining several variables that are used throughout the configuration process:

- `branch`: Specifies the branch to be used (default is "main").
- `location`: Specifies the Azure region (default is "WestUS3").

Next, the script defines various Azure Resource Group Names and Identity Variables used in resource management:

- `devBoxResourceGroupName`: Azure Resource Group for DevBox.
- `imageGalleryResourceGroupName`: Azure Resource Group for Image Gallery.
- `identityResourceGroupName`: Azure Resource Group for Identity.
- `networkResourceGroupName`: Azure Resource Group for Network Connectivity.
- `managementResourceGroupName`: Azure Resource Group for DevBox Management.

- `identityName`: Name of the identity used for image building.
- `customRoleName`: Name of the custom role assigned for image building.

Following that, the script sets the names for Image Gallery and various images within the gallery:

- `imageGalleryName`: Name of the Azure Image Gallery.
- `frontEndImageName`: Name of the FrontEnd image in the gallery.
- `backEndImageName`: Name of the BackEnd image in the gallery.
- `devCenterName`: Name of the Dev Center.

Finally, the script defines Network Variables:

- `vnetName`: Name of the Virtual Network.
- `subNetName`: Name of the Subnet.
- `networkConnectionName`: Name of the Network Connection.

## Architecture

**Working in progress..**

## Projects

This repository is structured around multiple projects:

1. **eShop**      - A reference .NET application implementing an eCommerce web site using a services-based architecture.

2. **Contoso**    - Contoso is a fictional company often used in Microsoft's documentation, training materials, and demonstrations. It is not a real company but serves as an example organization in various Microsoft products and services to illustrate how their software and solutions can be used in a business context. Contoso is used to create sample scenarios and data for educational purposes in the Microsoft ecosystem.

3. **Fabrikam**   - This reference implementation shows a set of best practices for building and running a microservices architecture on Microsoft Azure. This content is built on top of the AKS Secure Baseline, which is the recommended starting (baseline) infrastructure architecture for an AKS cluster.

4. **TailWind**   - A fictitious retail company showcasing the future of intelligent application experiences. These reference apps are all powered by the Azure cloud, built with best-in-class tools, and made smarter through data and AI.

## How to Use the Scripts

To effectively utilize the scripts contained in this repository:

```
Bash

# Access the deploy.sh cript folder
cd Deploy/Bash

# Run the script passing the Subscription Name as parameter
./deploy.sh <SubscriptionName>

```

## Contributing

We welcome contributions! If you'd like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your changes.
3. Make the desired changes or enhancements in your branch.
4. Submit a pull request for review.

## License

This project is open-source, licensed under the [MIT License](LICENSE).

---

For any queries or feedback, please open an issue or contact the maintainers. Happy coding! 🚀
