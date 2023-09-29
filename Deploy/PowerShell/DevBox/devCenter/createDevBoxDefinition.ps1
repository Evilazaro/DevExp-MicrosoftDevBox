# Best Practices Revised PowerShell Script

# Assigning input arguments to variables with more descriptive, camelCase names
param (
    [string]$subscriptionId,         # subscription ID
    [string]$location,               # location
    [string]$devBoxResourceGroupName,  # resource group name
    [string]$devCenterName,          # development center name
    [string]$galleryName,            # gallery name
    [string]$imageName,              # image name
    [string]$networkConnectionName   # network connection name
)

# Inform the user about the initialization step
Write-Host "Initializing script with subscriptionId: $subscriptionId, location: $location, devBoxResourceGroupName: $devBoxResourceGroupName, devCenterName: $devCenterName, galleryName: $galleryName, and imageName: $imageName."

# Construct necessary variables with camelCase naming conventions
$imageReferenceId = "/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/${galleryName}/images/${imageName}def/"
$devBoxDefinitionName = "devBox-$imageName"
$projectName = "eShop"
$poolName = "$imageName-pool"
$devBoxName = "$imageName-devbox"

# Echo the constructed variables
Write-Host "Constructed variables:
imageReferenceId: $imageReferenceId
devBoxDefinitionName: $devBoxDefinitionName
networkConnectionName: $networkConnectionName
projectName: $projectName
poolName: $poolName
devBoxName: $devBoxName"

# Creating a DevBox definition with camelCase variable names and added echo for step tracking
Write-Host "Creating DevBox definition..."
az devcenter admin devbox-definition create --location $location `
        --image-reference id=$imageReferenceId `
        --os-storage-type "ssd_256gb" `
        --sku name="general_i_8c32gb256ssd_v2" `
        --name $devBoxDefinitionName `
        --dev-center-name $devCenterName `
        --resource-group $devBoxResourceGroupName

Write-Host "DevBox definition created successfully."

# Creating DevBox Pools with added echo for step tracking
Write-Host "Creating DevBox Pools..."
.\devBox\devCenter\createDevBoxPools.ps1 $location $devBoxDefinitionName $networkConnectionName $poolName $projectName $devBoxResourceGroupName
Write-Host "DevBox Pools created successfully."

# Creating DevBox for Engineers with added echo for step tracking
Write-Host "Creating DevBox for Engineers..."
.\devBox\devCenter\createDevBoxforEngineers.ps1 $poolName $devBoxName $devCenterName $projectName
Write-Host "DevBox for Engineers created successfully."
