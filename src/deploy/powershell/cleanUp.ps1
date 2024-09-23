<#
.SYNOPSIS
    This script cleans up the deployment environment in Azure.

.DESCRIPTION
    This script deletes role assignments, custom roles, and resource groups in Azure. It takes no parameters and uses predefined constants for resource names and IDs.

.PARAMETER None

.EXAMPLE
    .\CleanUp.ps1
#>

# Exit immediately if a command exits with a non-zero status
$ErrorActionPreference = "Stop"

# Clear the terminal screen
Clear-Host

Write-Host "Cleaning up the deployment environment..."

# Azure Resource Group Names Constants
$devBoxResourceGroupName = "petv2DevBox-rg"
$imageGalleryResourceGroupName = "petv2ImageGallery-rg"
$identityResourceGroupName = "petv2IdentityDevBox-rg"
$networkResourceGroupName = "petv2NetworkConnectivity-rg"
$managementResourceGroupName = "petv2DevBoxManagement-rg"
$subscriptionId = (az account show --query id --output tsv)

# Identity Parameters Constants
$customRoleName = "petv2BuilderRole"

# Function to delete a resource group
function Delete-ResourceGroup {
    param (
        [string]$resourceGroupName
    )

    $groupExists = az group exists --name $resourceGroupName

    if ($groupExists -eq "true") {
        Write-Host "Deleting resource group: $resourceGroupName..."
        az group delete --name $resourceGroupName --yes --no-wait
        Write-Host "Resource group $resourceGroupName deletion initiated."
    } else {
        Write-Host "Resource group $resourceGroupName does not exist. Skipping deletion."
    }
}

# Function to remove a role assignment
function Remove-RoleAssignment {
    param (
        [string]$roleId,
        [string]$subscription
    )

    Write-Host "Checking the role assignments for the identity..."

    if (-not $roleId) {
        Write-Host "Role not defined. Skipping role assignment deletion."
        return
    }

    $assignmentExists = az role assignment list --role $roleId --scope /subscriptions/$subscription

    if (-not $assignmentExists -or $assignmentExists -eq "[]") {
        Write-Host "'$roleId' role assignment does not exist. Skipping deletion."
    } else {
        Write-Host "Removing '$roleId' role assignment from the identity..."
        az role assignment delete --role $roleId --scope /subscriptions/$subscription
        Write-Host "'$roleId' role assignment successfully removed."
    }
}

# Function to delete a custom role
function Delete-CustomRole {
    param (
        [string]$roleName
    )

    Write-Host "Deleting the '$roleName' role..."
    $roleExists = az role definition list --name $roleName

    if (-not $roleExists -or $roleExists -eq "[]") {
        Write-Host "'$roleName' role does not exist. Skipping deletion."
        return
    }

    az role definition delete --name $roleName

    while ((az role definition list --name $roleName --query [].roleName -o tsv) -eq $roleName) {
        Write-Host "Waiting for the role to be deleted..."
        Start-Sleep -Seconds 10
    }

    Write-Host "'$roleName' role successfully deleted."
}

# Function to delete role assignments
function Delete-RoleAssignments {
    # Deleting role assignments and role definitions
    $roleNames = @('Owner', 'Managed Identity Operator', 'DevCenter Dev Box User', $customRoleName)
    foreach ($roleName in $roleNames) {
        Write-Host "Getting the role ID for '$roleName'..."
        $roleId = az role definition list --name $roleName --query [].name --output tsv
        if (-not $roleId) {
            Write-Host "Role ID for '$roleName' not found. Skipping role assignment deletion."
            continue
        }
        Remove-RoleAssignment -roleId $roleId -subscription $subscriptionId
    }
}

# Function to clean up resources
function Clean-UpResources {
    Delete-RoleAssignments
    Delete-CustomRole -roleName $customRoleName
    Delete-ResourceGroup -resourceGroupName $devBoxResourceGroupName
    Delete-ResourceGroup -resourceGroupName $imageGalleryResourceGroupName
    Delete-ResourceGroup -resourceGroupName $identityResourceGroupName
    Delete-ResourceGroup -resourceGroupName $networkResourceGroupName
    Delete-ResourceGroup -resourceGroupName $managementResourceGroupName
    Delete-ResourceGroup -resourceGroupName "NetworkWatcherRG"
    Delete-ResourceGroup -resourceGroupName "Default-ActivityLogAlerts"
    Delete-ResourceGroup -resourceGroupName "DefaultResourceGroup-WUS2"
}

# Main script execution
Clean-UpResources