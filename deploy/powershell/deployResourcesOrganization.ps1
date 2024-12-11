# PowerShell script to deploy Azure resources for the organization

param (
    [string]$devBoxResourceGroupName='ContosoDevEx-rg',
    [string]$networkResourceGroupName='ContosoDevEx-Network-rg',
    [string]$managementResourceGroupName='ContosoDevEx-Management-rg',
    [string]$location='northuscentral'
)

# Function to create an Azure resource group
function Create-ResourceGroup {
    param (
        [string]$resourceGroupName,
        [string]$location
    )

    if ([string]::IsNullOrEmpty($resourceGroupName) -or [string]::IsNullOrEmpty($location)) {
        Write-Output "Error: Missing required parameters."
        Write-Output "Usage: Create-ResourceGroup -resourceGroupName <resourceGroupName> -location <location>"
        return 1
    }

    Write-Output "Creating Azure Resource Group: $resourceGroupName in $location"

    $result = az group create --name $resourceGroupName --location $location `
        --tags `
        "division=PlatformEngineeringTeam-DevEx" `
        "Environment=Production" `
        "offering=DevBox-as-a-Service"

    if ($result) {
        Write-Output "Resource group '$resourceGroupName' created successfully."
    } else {
        Write-Output "Error: Failed to create resource group '$resourceGroupName'."
        return 1
    }
}

# Function to deploy resources for the organization
function Deploy-ResourcesOrganization {
    Create-ResourceGroup -resourceGroupName $devBoxResourceGroupName -location $location
    Create-ResourceGroup -resourceGroupName $networkResourceGroupName -location $location
    Create-ResourceGroup -resourceGroupName $managementResourceGroupName -location $location
}

# Function to validate input parameters
function Validate-Inputs {
    if ([string]::IsNullOrEmpty($devBoxResourceGroupName) -or [string]::IsNullOrEmpty($networkResourceGroupName) -or [string]::IsNullOrEmpty($managementResourceGroupName) -or [string]::IsNullOrEmpty($location)) {
        Write-Output "Error: Missing required parameters."
        Write-Output "Usage: .\deployResourcesOrganization.ps1 -devBoxResourceGroupName <devBoxResourceGroupName> -networkResourceGroupName <networkResourceGroupName> -managementResourceGroupName <managementResourceGroupName> -location <location>"
        return 1
    }
}

# Main script execution
Validate-Inputs
Deploy-ResourcesOrganization