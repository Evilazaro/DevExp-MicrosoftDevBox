# Dev Experience with Microsoft DevBox

Welcome to the Dev Experience with Microsoft DevBox repository! This repository demonstrates how to deploy Microsoft DevBox for Contoso's Software Development Engineers to expedite their onboarding process and streamline project integration.

## Table of Contents

- [Overview](#overview)
- [Microsoft DevBox Overview](#microsoft-devbox-overview)
- [Build and Deploy Status](#build-and-deploy-status)
- [Solution Architecture](#solution-architecture)
- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview

Contoso aims to enhance the developer experience by leveraging Microsoft DevBox. This repository provides a comprehensive guide and resources to deploy and manage Microsoft DevBox environments efficiently.

## Microsoft DevBox Overview

Microsoft DevBox is a cloud-based service that provides pre-configured, secure, and scalable development environments. It allows developers to quickly set up and start coding without worrying about the underlying infrastructure. DevBox integrates seamlessly with Azure services, providing a robust platform for development and testing.

For more information, please refer to the official Microsoft DevBox documentation:
- [Microsoft DevBox Overview](https://docs.microsoft.com/en-us/azure/dev-box/overview)
- [Getting Started with Microsoft DevBox](https://docs.microsoft.com/en-us/azure/dev-box/get-started)
- [Microsoft DevBox Pricing](https://azure.microsoft.com/en-us/pricing/details/dev-box/)


## Build and Deploy Status

| Build | Deploy |
|:-----:|:------:|
| [![Test Login To Azure](https://github.com/Evilazaro/MicrosoftDevBox/actions/workflows/testLoginToAzure.yaml/badge.svg)](https://github.com/Evilazaro/MicrosoftDevBox/actions/workflows/testLoginToAzure.yaml) [![DevBox as a Service CI](https://github.com/Evilazaro/MicrosoftDevBox/actions/workflows/devBox-CI.yaml/badge.svg)](https://github.com/Evilazaro/MicrosoftDevBox/actions/workflows/devBox-CI.yaml) | [![DevBox as a Service CI and CD](https://github.com/Evilazaro/MicrosoftDevBox/actions/workflows/deployDevBox.yaml/badge.svg)](https://github.com/Evilazaro/MicrosoftDevBox/actions/workflows/deployDevBox.yaml) [![Clean UP Dev Experience with Microsoft DevBox Deployment](https://github.com/Evilazaro/DevExp-MicrosoftDevBox/actions/workflows/cleanUpDeployment.yaml/badge.svg)](https://github.com/Evilazaro/DevExp-MicrosoftDevBox/actions/workflows/cleanUpDeployment.yaml) [![Dev Experience with Microsoft DevBox New Release](https://github.com/Evilazaro/DevExp-MicrosoftDevBox/actions/workflows/devExpNewRelease.yaml/badge.svg)](https://github.com/Evilazaro/DevExp-MicrosoftDevBox/actions/workflows/devExpNewRelease.yaml) |

## Solution Architecture

![Solution Architecture](./images/ContosoDevBox.png)

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

### Prerequisites

- [Azure Subscription](https://azure.microsoft.com/en-us/free/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Bicep CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- [GitHub CLI](https://cli.github.com/)
- [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli)

### Installation

1. **Clone the repository:**
    
    Bash
    ```sh
    git clone https://github.com/Evilazaro/MicrosoftDevBox.git
    cd MicrosoftDevBox
    ```
    PowerShell
    ```powershell
    git clone https://github.com/Evilazaro/MicrosoftDevBox.git
    cd MicrosoftDevBox
    ```

2. **Login to Azure:**
    
    Bash 
    ```sh
    az login
    ```
    PowerShell
    ```powershell
    az login 
    ```
3. **Deploy the Bicep templates:**
    ```sh
    az deployment group create --resource-group <your-resource-group> --template-file ./bicep/main.bicep
    ```

## Usage

After the deployment, you can manage and monitor the DevBox environments using the Azure portal or Azure CLI.

## Contributing

We welcome contributions to enhance the Dev Experience with Microsoft DevBox. Please follow the [contributing guidelines](CONTRIBUTING.md) to submit your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.