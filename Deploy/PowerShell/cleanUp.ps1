# Using $ErrorActionPreference to stop on any errors
$ErrorActionPreference = "Stop"

# Declare resource group names
$galleryResourceGroup = 'Contoso-Base-Images-Engineers-rg'
$devBoxResourceGroupName = 'Contoso-DevBox-rg'

# Function to delete a resource group
function Delete-ResourceGroup {
    param (
        [string]$resourceGroupName
    )

    # Check if the resource group exists before trying to delete it
    $groupExists = az group exists --name $resourceGroupName
    if ($groupExists -eq $true) {
        Write-Host "Deleting resource group: $resourceGroupName..."

        # Using `az group delete` to delete the specified resource group
        az group delete --name $resourceGroupName --yes --no-wait
        Write-Host "Resource group $resourceGroupName deletion initiated."
    }
    else {
        Write-Host "Resource group $resourceGroupName does not exist. Skipping deletion."
    }
}

# Delete the gallery resource group
Delete-ResourceGroup -resourceGroupName $galleryResourceGroup

# Delete the devBox resource group
Delete-ResourceGroup -resourceGroupName $devBoxResourceGroupName

Write-Host "Script execution completed."
