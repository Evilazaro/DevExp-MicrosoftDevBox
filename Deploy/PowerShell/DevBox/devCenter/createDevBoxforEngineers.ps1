# Check if the correct number of arguments has been provided
if ($args.Length -ne 4) {
    Write-Host "Usage: <ScriptName> <poolName> <devBoxName> <devCenterName> <projectName>"
    exit 1
}

# Assign command line arguments to variables with meaningful names
$poolName = $args[0]
$devBoxName = $args[1]
$devCenterName = $args[2]
$projectName = $args[3]

# Inform the user about the values received
Write-Host "Creating Dev Box with:"
Write-Host "Pool Name: $poolName"
Write-Host "Dev Box Name: $devBoxName"
Write-Host "Dev Center Name: $devCenterName"
Write-Host "Project Name: $projectName"

# Obtain the current Azure logged user name and ID
Write-Host "Retrieving current Azure logged user information..."
$currentUserName = az account show --query user.name -o tsv

if (-not $currentUserName) {
    Write-Host "Error: Couldn't retrieve the current Azure user name. Exiting."
    exit 1
}

Write-Host "Current Azure User Name: $currentUserName"

$currentAzureLoggedUserID = az ad user show --id $currentUserName --query id -o tsv

if (-not $currentAzureLoggedUserID) {
    Write-Host "Error: Couldn't retrieve the current Azure user ID. Exiting."
    exit 1
}

Write-Host "Current Azure User ID: $currentAzureLoggedUserID"

# Create a dev box with specified parameters
Write-Host "Creating Dev Box..."
az devcenter dev dev-box create `
    --pool-name $poolName `
    --name $devBoxName `
    --dev-center-name $devCenterName `
    --project-name $projectName `
    --user-id $currentAzureLoggedUserID `
    --no-wait

# Check if the dev box creation was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "Dev Box '$devBoxName' has been created successfully!"
} else {
    Write-Host "Error: Dev Box creation failed."
    exit 1
}
