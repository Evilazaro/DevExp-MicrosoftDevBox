# Microsoft DevBox Automation

Welcome to the Microsoft DevBox demo repository! This repository contains a set of scripts designed to streamline the provisioning and deployment of Microsoft DevBox environments on Azure. The main orchestrator script is `deploy.sh`, which automates the setup of various Azure resources necessary for a fully functional DevBox environment.

## Table of Contents

1. [Introduction](#introduction)
   - [Solution Architecture](#solution-architecture) 
2. [Repository Structure](#repository-structure)
3. [How to Use the Scripts](#how-to-use-the-scripts)
   - [Prerequisites](#prerequisites)
   - [Deployment Steps](#deployment-steps)
   - [Script Overview](#script-overview)
4. [Customization](#customization)
5. [Error Handling](#error-handling)
6. [Contributing](#contributing)
7. [License](#license)

## Introduction

This epository provides a collection of scripts to automate the provisioning and deployment of Microsoft DevBox environments in Azure. The main script, `deploy.sh`, handles the orchestration of various Azure resources.

### Solution Architecture

![Solution Architecture](./images/ContosoDevBox.png)

## Repository Structure

- **src/deploy/**: This directory contains the following deployment scripts and templates, each serving a specific purpose in the DevBox setup process:
  - **[identity](./src/deploy/identity/)**: Configures the identities required for accessing and managing DevBox resources, including service principals and managed identities.
      - ***Scripts***: login.sh, registerFeatures.sh, createIdentity.sh, and createUserAssignedManagedIdentity.sh
  - **[network](./src/deploy/network/)**: Sets up the virtual network, subnets, and other networking components necessary for the DevBox environment.
      - ***Scripts***: deployVnet.sh, and createNetWorkConnection.sh
  - **`computeGallery`**: Deploys the Azure Compute Gallery, where VM images are stored and managed.
      - ***Scripts***: deployComputeGallery.sh, and createVMImageTemplate.sh
  - **`devCenter`**: Configures the Dev Center environment, including setting up necessary infrastructure and resources.
      - ***Scripts***: deployDevCenter.sh, createDevCenterProject.sh, createDevBoxDefinition.sh, and createDevBoxPools.sh

The main orchestrator script, `deploy.sh`, sequentially calls these scripts to ensure a smooth and consistent deployment process. Each script is designed to handle specific aspects of the infrastructure setup, ensuring that all necessary components are correctly configured and deployed.

## How to Use the Scripts

### Prerequisites

#### Windows

1. **PowerShell**:
2. **Git for Windows**: 
3. **GitHub CLI**:
4. **Azure CLI**: Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
5. **Azure CLI for Developers**:
6. **VS Code for Windows**
7. **Azure Subscription**: Ensure you have access to an Azure subscription. 

You can install all the dependencies at once running the following PowerShell script:

```powershell
cd \src\deploy\dependencies

.\installDependencies
```
### Linux

1. **PowerShell**:
2. **Git for Windows**: 
3. **GitHub CLI**:
4. **Azure CLI**: Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
5. **Azure CLI for Developers**:
6. **VS Code for Windows**
7. **Azure Subscription**: Ensure you have access to an Azure subscription. 

```bash
cd deploy
```

### Microsoft DevBox Deploy

1. **Clone the Repository**: Clone this repository to your local machine.
   ```bash
   git clone https://github.com/Evilazaro/MicrosoftDevBox.git
   
   cd MicrosoftDevBox/src/deploy

   ./deploy.sh <azureSubscriptionName> <buildImageParameter>
  
### 5. Configuration:

In this section, we will explain the configuration part of the Bash script. This part of the script defines various variables and functions related to Azure resource management, identity, network, and image gallery.

### 5.1 Variables

The script starts by defining several variables that are used throughout the configuration process:

- `branch`: Specifies the branch to be used (default is "main").
- `location`: Specifies the Azure region (default is "WestUS3").

Next, the script defines various Azure Resource Group Names and Identity Variables used in resource management:

#### Script Parameters

- `Subscription Name`: 
- `Build Image`: 

### Global Variables 

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

### Contributing

We welcome contributions! If you'd like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your changes.
3. Make the desired changes or enhancements in your branch.
4. Submit a pull request for review.

### License

This project is open-source, licensed under the [MIT License](LICENSE).

---

For any queries or feedback, please open an issue or contact the maintainers. Happy coding! 🚀
