# Define parameters
param (
    [string]$location,
    [string]$subscriptionId,
    [string]$devBoxResourceGroupName,
    [string]$devCenterName
)

# Define other variables
$description = "Sample .NET Core reference application, powered by Microsoft"
$projectName = "eShop"
$maxDevBoxesPerUser = "10"

# Check for mandatory parameters and print usage information if they are not provided
if (-not $location -or -not $subscriptionId -or -not $devBoxResourceGroupName -or -not $devCenterName) {
    Write-Host "Usage: .\script_name.ps1 <location> <subscriptionId> <devBoxResourceGroupName> <devCenterName>"
    exit 1
}

# Construct the dev-center-id
$devCenterId = "/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName"

# Inform the user about the action to be performed
Write-Host "Creating a new devcenter admin project in Azure..."
Write-Host "Location: $location"
Write-Host "Subscription ID: $subscriptionId"
Write-Host "Resource Group Name: $devBoxResourceGroupName"
Write-Host "Dev Center Name: $devCenterName"
Write-Host "Description: $description"
Write-Host "Project Name: $projectName"
Write-Host "Max Dev Boxes Per User: $maxDevBoxesPerUser"

# Run the Azure CLI command to create a devcenter admin project
az devcenter admin project create `
    --location "$location" `
    --description "$description" `
    --dev-center-id "$devCenterId" `
    --name "$projectName" `
    --resource-group "$devBoxResourceGroupName" `
    --max-dev-boxes-per-user "$maxDevBoxesPerUser" `
    --tags  "division=Contoso-Platform" `
            "Environment=Prod" `
            "offer=Contoso-DevWorkstation-Service" `
            "Team=Engineering" `
            "solution=eShop" `
            "businessUnit=e-Commerce"

# Check the status of the last command run and inform the user
if ($LASTEXITCODE -eq 0) {
    Write-Host "Devcenter admin project '$projectName' has been created successfully!"
} else {
    Write-Host "Failed to create devcenter admin project '$projectName'." -ForegroundColor Red
    exit 2
}
