# Exit script if any command fails
$ErrorActionPreference = "Stop"

# Validate number of arguments
if ($args.Count -ne 9) {
    Write-Output "Usage: <ScriptName> <devCenterName> <networkConnectionName> <imageGalleryName> <location> <identityName> <devBoxResourceGroupName> <networkResourceGroupName> <identityResourceGroupName> <imageGalleryResourceGroupName>"
    exit 1
}

# Assign arguments to variables
$devCenterName = $args[0]
$networkConnectionName = $args[1]
$imageGalleryName = $args[2]
$location = $args[3]
$identityName = $args[4]
$devBoxResourceGroupName = $args[5]
$networkResourceGroupName = $args[6]
$identityResourceGroupName = $args[7]
$imageGalleryResourceGroupName = $args[8]

Write-Output "Starting to deploy Dev Center with the following parameters:"
Write-Output "Dev Center Name: $devCenterName"
Write-Output "Network Connection Name: $networkConnectionName"
Write-Output "Image Gallery Name: $imageGalleryName"
Write-Output "Location: $location"
Write-Output "Identity Name: $identityName"
Write-Output "DevBox Resource Group Name: $devBoxResourceGroupName"
Write-Output "Network Resource Group Name: $networkResourceGroupName"
Write-Output "Identity Resource Group Name: $identityResourceGroupName"
Write-Output "Image Gallery Resource Group Name: $imageGalleryResourceGroupName"

# Define other constants
$branch = "Dev"
$templateFileUri = "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/Deploy/ARMTemplates/devBox/devCentertemplate.json"

Write-Output "Fetching network connection id..."
$networkConnectionId = az devcenter admin network-connection list --resource-group $networkResourceGroupName --query "[0].id" --output tsv

Write-Output "Fetching compute gallery id..."
$computeGalleryId = az sig show --resource-group $imageGalleryResourceGroupName --gallery-name $imageGalleryName --query id --output tsv

Write-Output "Fetching user identity id..."
$userIdentityId = az identity show --resource-group $identityResourceGroupName --name $identityName --query id --output tsv

Write-Output "Creating deployment group..."
az deployment group create `
    --name "$devCenterName" `
    --resource-group "$devBoxResourceGroupName" `
    --template-uri $templateFileUri `
    --parameters `
        devCenterName="$devCenterName" `
        networkConnectionId="$networkConnectionId" `
        computeGalleryId="$computeGalleryId" `
        location="$location" `
        networkConnectionName="$networkConnectionName" `
        userIdentityId="$userIdentityId" `
        computeGalleryImageName="$imageGalleryName"

Write-Output "Deployment of Dev Center is complete."
