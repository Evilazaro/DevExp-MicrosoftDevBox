# Microsoft Dev Box Automation Demo

This repository contains automation scripts that facilitate various Azure tasks like resource group creation, image creation, and deployment.

## Script Description

The primary script `deploy.sh` automates the deployment of the Microsoft Dev Box. It handles the following tasks:
- Logs into Azure.
- Sets up static variables.
- Creates Azure resources.
- Deploys Azure Compute Gallery.
- Builds virtual machine images.
- Deploys Microsoft DevBox.

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured.
- Appropriate permissions to create Azure resources.
- Internet access to fetch ARM templates.
- Ensure all subsidiary scripts have execute permissions.

## Usage

### Bash

```bash
chmod +x deploy.sh
./deploy.sh <Azure_Subscription_Name>
```

### PowerShell
```powershell
# Grant execute permissions to the script
Set-ExecutionPolicy Bypass -Scope Process -Force

# Run the script
& './deploy.sh' <Azure_Subscription_Name>

