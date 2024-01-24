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

### 3. Required Directory Structure:
The script assumes the existence of several other scripts in a specific directory structure. Ensure these scripts exist and are executable. If these are part of a repository, clone or download the repository first.

#### 4. Required Directory Structure:
The script assumes the existence of several other scripts in a specific directory structure. Ensure these scripts exist and are executable:
  
- `./identity/login.sh`
- `./identity/createIdentity.sh`
- `./identity/registerFeatures.sh`
- `./identity/createUserAssignedManagedIdentity.sh`
- `./network/deployVnet.sh`
- `./network/createNetWorkConnection.sh`
- `./devBox/computeGallery/deployComputeGallery.sh`
- `./devBox/devCenter/deployDevCenter.sh`
- `./devBox/devCenter/createDevCenterProject.sh`
- `./devBox/computeGallery/createVMImageTemplate.sh`
- `./devBox/devCenter/createDevBoxDefinition.sh`

### 5. Configuration:
- **Variables**: At the beginning of the script, several variables are defined (like `branch`, `location`, etc.). Review and adjust these values if necessary to match your Azure environment and naming conventions.

## Architecture

Provide a brief description or diagram about the architecture. Consider using diagrams or flowcharts to better illustrate the architecture. Add the link or embed the image here.

## Projects

This repository is structured around multiple projects:

1. **eShop** - Brief description about eShop
2. **Contoso** - Brief description about Contoso
3. **Fabrikam** - Brief description about Fabrikam
4. **TailWind** - Brief description about TailWind

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
