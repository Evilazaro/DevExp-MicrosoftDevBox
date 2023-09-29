# Declaring Variables
.\Identity\login.ps1 Evilazaro-CSA-Self-Learning
# Resources Organization
$subscriptionId = (Get-AzureRmContext).Subscription.Id
$devBoxResourceGroupName = 'ContosoFabric-DevBox-RG'
$imageGalleryResourceGroupName = 'ContosoFabric-ImageGallery-RG'
$identityResourceGroupName = 'ContosoFabric-Identity-DevBox-RG'
$networkResourceGroupName = 'eShop-Network-Connectivity-RG'
$managementResourceGroupName = 'ContosoFabric-DevBox-Management-RG'
$networkWatcherResourceGroupName = 'NetworkWatcherRG'
$location = 'WestUS3'

# Identity
$identityName = 'ContosoFabricDevBoxImgBldId'
$customRoleName = 'ContosoFabricBuilderRole'

# Function to delete a resource group
function Delete-ResourceGroup {
    param (
        [string]$resourceGroupName
    )

    if (Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue) {
        Write-Host "Deleting resource group: $resourceGroupName..."
        Remove-AzureRmResourceGroup -Name $resourceGroupName -Force -AsJob
        Write-Host "Resource group $resourceGroupName deletion initiated."
    } else {
        Write-Host "Resource group $resourceGroupName does not exist. Skipping deletion."
    }
}

# Function to remove a role
function Remove-Role {
    param (
        [string]$customRoleName
    )

    $output = Get-AzureRmRoleDefinition -Name $customRoleName -ErrorAction SilentlyContinue

    if ($null -eq $output) {
        Write-Host "'$customRoleName' role does not exist. Skipping deletion."
    } else {
        Write-Host "Deleting the '$customRoleName' role..."
        Remove-AzureRmRoleDefinition -Name $customRoleName -Force
        Write-Host "'$customRoleName' role successfully deleted."
    }
}


# Function to remove a role assignment
function Remove-RoleAssignment {
    param (
        [string]$roleId,
        [string]$subscriptionId
    )

    Write-Host "Checking the role assignments for the identity..."

    if ([string]::IsNullOrEmpty($roleId)) {
        Write-Host "Role not defined. Skipping role assignment deletion."
        return
    }

    $output = Get-AzureRmRoleAssignment -RoleDefinitionId $roleId -Scope "/subscriptions/$subscriptionId" -ErrorAction SilentlyContinue
    
    if ($null -eq $output) {
        Write-Host "'$roleId' role assignment does not exist. Skipping deletion."
    } else {
        Write-Host "Removing '$roleId' role assignment from the identity..."
        Remove-AzRoleAssignment -RoleDefinitionId $roleId -Scope "/subscriptions/$subscriptionId" -Force
        Write-Host "'$roleId' role assignment successfully removed."
    }
}

# Deleting role assignments and role definitions
$roleNames = @('Owner', 'Managed Identity Operator', 'Reader', 'DevCenter Dev Box User', $customRoleName)

foreach ($roleName in $roleNames) {
    Write-Host "Getting the role ID for '$roleName'..."
    $roleId = (Get-AzureRmRoleDefinition -Name $roleName).Id

    Remove-RoleAssignment -roleId $roleId -subscriptionId $subscriptionId
}

Remove-Role -customRoleName $customRoleName

# Deleting resource groups
Delete-ResourceGroup -resourceGroupName $devBoxResourceGroupName
Delete-ResourceGroup -resourceGroupName $imageGalleryResourceGroupName
Delete-ResourceGroup -resourceGroupName $identityResourceGroupName
Delete-ResourceGroup -resourceGroupName $networkResourceGroupName
Delete-ResourceGroup -resourceGroupName $managementResourceGroupName
Delete-ResourceGroup -resourceGroupName $networkWatcherResourceGroupName
Delete-ResourceGroup -resourceGroupName "Default-ActivityLogAlerts"
Delete-ResourceGroup -resourceGroupName "DefaultResourceGroup-WUS2"
