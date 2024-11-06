
# Exit immediately if a command exits with a non-zero status
$ErrorActionPreference = "Stop"

# Define variables
$location = "northuscentral"
$solutionName = "PetDx"
$devBoxResourceGroupName = "PetDx-rg"
$networkResourceGroupName = "PetDx-Network-rg"
$managementResourceGroupName = "PetDx-Management-rg"

# Function to deploy management resources
function Deploy-ManagementResources {
    Write-Output "Deploying management resources..."
    Write-Output "Management Resource Group: $managementResourceGroupName"
    Write-Output "Location: $location"

    try {
        az deployment group create --resource-group $managementResourceGroupName `
            --template-file "..\management\logAnalytics\deploy.bicep" `
            --parameters solutionName=$solutionName
        Write-Output "Management resources deployed successfully."
    } catch {
        Write-Error "Failed to deploy management resources."
        exit 1
    }
}

# Function to deploy network resources
function Deploy-NetworkResources {
    Write-Output "Deploying network resources..."
    Write-Output "Network Resource Group: $networkResourceGroupName"
    Write-Output "Location: $location"

    try {
        az deployment group create --resource-group $networkResourceGroupName `
            --template-file "..\network\deploy.bicep" `
            --parameters solutionName=$solutionName managementResourceGroupName=$managementResourceGroupName
        Write-Output "Network resources deployed successfully."
    } catch {
        Write-Error "Failed to deploy network resources."
        exit 1
    }
}

# Function to deploy Dev Center resources
function Deploy-DevCenterResources {
    Write-Output "Deploying Dev Center resources..."
    Write-Output "Dev Center Resource Group: $devBoxResourceGroupName"
    Write-Output "Location: $location"

    try {
        az deployment group create --resource-group $devBoxResourceGroupName `
            --template-file "..\devBox\deploy.bicep" `
            --parameters solutionName=$solutionName managementResourceGroupName=$managementResourceGroupName
        Write-Output "Dev Center resources deployed successfully."
    } catch {
        Write-Error "Failed to deploy Dev Center resources."
        exit 1
    }
}

# Main script execution
Write-Output "Starting deployment script..."

# Check if Azure CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI could not be found. Please install it and try again."
    exit 1
}

# Call the function to deploy management resources
Deploy-ManagementResources

# Call the function to deploy network resources
Deploy-NetworkResources

# Call the function to deploy Dev Center resources
Deploy-DevCenterResources

Write-Output "Deployment script completed."