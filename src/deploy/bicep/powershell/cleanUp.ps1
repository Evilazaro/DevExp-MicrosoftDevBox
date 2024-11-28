# PowerShell script to clean up Azure resources

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
$ErrorActionPreference = "Stop"
$WarningPreference = "Stop"

# Azure Resource Group Names Constants
$solutionName = "ContosoIpeDx"
$devBoxResourceGroupName = "$solutionName-rg"
$networkResourceGroupName = "$solutionName-Management-rg"
$managementResourceGroupName = "$solutionName-Network-rg"

# Identity Parameters Constants
$customRoleName = "eShopPetBuilderRole"

$subscriptionId = (az account show --query id --output tsv)

# Function to delete a resource group
function Delete-ResourceGroup {
    param (
        [string]$resourceGroupName
    )

    $groupExists = (az group exists --name $resourceGroupName)

    if ($groupExists -eq "true") {
        # List and delete all deployments in the resource group
        $deployments = az deployment group list --resource-group $resourceGroupName --query "[].name" -o tsv
        foreach ($deployment in $deployments) {
            Write-Output "Deleting deployment: $deployment"
            az deployment group delete --resource-group $resourceGroupName --name $deployment
            Write-Output "Deployment $deployment deleted."
        }
        Start-Sleep -Seconds 10
        Write-Output "Deleting resource group: $resourceGroupName..."
        az group delete --name $resourceGroupName --yes --no-wait
        Write-Output "Resource group $resourceGroupName deletion initiated."
    } else {
        Write-Output "Resource group $resourceGroupName does not exist. Skipping deletion."
    }
}

# Function to remove a role assignment
function Remove-RoleAssignment {
    param (
        [string]$roleId,
        [string]$subscription
    )

    Write-Output "Checking the role assignments for the identity..."

    if ([string]::IsNullOrEmpty($roleId)) {
        Write-Output "Role not defined. Skipping role assignment deletion."
        return
    }

    $assignmentExists = az role assignment list --role $roleId --scope /subscriptions/$subscription
    if ([string]::IsNullOrEmpty($assignmentExists) -or $assignmentExists -eq "[]") {
        Write-Output "'$roleId' role assignment does not exist. Skipping deletion."
    } else {
        Write-Output "Removing '$roleId' role assignment from the identity..."
        az role assignment delete --role $roleId
        Write-Output "'$roleId' role assignment successfully removed."
    }
}

# Function to delete a custom role
function Delete-CustomRole {
    param (
        [string]$roleName
    )

    Write-Output "Deleting the '$roleName' role..."
    $roleExists = az role definition list --name $roleName

    if ([string]::IsNullOrEmpty($roleExists) -or $roleExists -eq "[]") {
        Write-Output "'$roleName' role does not exist. Skipping deletion."
        return
    }

    az role definition delete --name $roleName

    while ((az role definition list --name $roleName --query [].roleName -o tsv) -eq $roleName) {
        Write-Output "Waiting for the role to be deleted..."
        Start-Sleep -Seconds 10
    }
    Write-Output "'$roleName' role successfully deleted."
}

# Function to delete role assignments
function Delete-RoleAssignments {
    # Deleting role assignments and role definitions
    $roles = @('Owner', 'Managed Identity Operator', $customRoleName)
    foreach ($roleName in $roles) {
        Write-Output "Getting the role ID for '$roleName'..."
        $roleId = az role definition list --name $roleName --query [].name --output tsv
        if ([string]::IsNullOrEmpty($roleId)) {
            Write-Output "Role ID for '$roleName' not found. Skipping role assignment deletion."
            continue
        } else {
            Write-Output "Role ID for '$roleName' is '$roleId'."
            Write-Output "Removing '$roleName' role assignment..."
        }
        Remove-RoleAssignment -roleId $roleId -subscription $subscriptionId
    }
}

# Function to clean up resources
function CleanUp-Resources {
    Clear-Host
    Delete-RoleAssignments
    Delete-ResourceGroup -resourceGroupName $devBoxResourceGroupName
    Delete-ResourceGroup -resourceGroupName $networkResourceGroupName
    Delete-ResourceGroup -resourceGroupName $managementResourceGroupName
    Delete-ResourceGroup -resourceGroupName "NetworkWatcherRG"
    Delete-ResourceGroup -resourceGroupName "Default-ActivityLogAlerts"
    Delete-ResourceGroup -resourceGroupName "DefaultResourceGroup-WUS2"
    Delete-CustomRole -roleName $customRoleName
}

# Main script execution
CleanUp-Resources