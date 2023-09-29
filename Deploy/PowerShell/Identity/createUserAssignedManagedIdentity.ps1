# Parameters
param (
    [string]$identityResourceGroupName, # Resource group of the managed identity
    [string]$subscriptionId,           # Azure Subscription ID
    [string]$identityName,             # Name of the Managed Identity
    [string]$customRoleName            # Custom Role Name
)

# Constants
$outputFile = ".\downloadedTempTemplates\identity\aibroleImageCreation-template.json"
$windows365identityName = "0af06dc6-e4b5-4f28-818e-e78e62d137a5"
$branch = "Dev"

# Derive Current User Details
$currentUserName = az account show --query user.name -o tsv | Out-String | Trim # Azure Logged in Username
$currentAzureLoggedUser = az ad user show --id $currentUserName --query id -o tsv | Out-String | Trim # Azure Logged in User ID
$identityId = az identity show --name $identityName --resource-group $identityResourceGroupName --query principalId -o tsv | Out-String | Trim # Managed Identity ID

function createCustomRole {
    param (
        [string]$subscriptionId,
        [string]$group,
        [string]$outputFile,
        [string]$customRoleName
    )

    $templateUrl = "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/Deploy/ARMTemplates/identity/aibRoleImageCreation-template.json"
    
    Write-Host "Starting custom role creation..."
    Write-Host "Downloading image template from ${templateUrl}..."

    try {
        Invoke-WebRequest -Uri $templateUrl -Headers @{"Cache-Control"="no-cache"; "Pragma"="no-cache"} -OutFile $outputFile
    }
    catch {
        Write-Host "Error: Failed to download the image template."
        exit 3
    }

    Write-Host "Successfully downloaded the image template to ${outputFile}."
    Write-Host "Custom Role Name is ${customRoleName}"

    Write-Host "Updating placeholders in the template..."
    
    (Get-Content $outputFile) -replace '<subscriptionId>', $subscriptionId -replace '<rgName>', $group -replace '<roleName>', $customRoleName | Set-Content $outputFile

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to update placeholders in the template."
        exit 4
    }

    Write-Host "Template placeholders updated."
    az role definition create --role-definition $outputFile | Out-Null
    Write-Host "Custom role creation completed."
}

function assignRole {
    param (
        [string]$identityId,
        [string]$roleName,
        [string]$subscriptionId
    )

    Write-Host "Starting role assignment..."
    Write-Host "Assigning '$roleName' role to the identity $identityId for subscriptionId ${subscriptionId}"

    try {
        az role assignment create --assignee $identityId --role $roleName --scope /subscriptions/$subscriptionId | Out-Null
        Write-Host "'$roleName' role successfully assigned to the identity in the subscriptionId."
    }
    catch {
        Write-Host "Error: Failed to assign '$roleName' role to the identity."
        exit 2
    }

    Write-Host "Role assignment completed."
}

# Main Script Execution
Write-Host "Script started."

createCustomRole $subscriptionId $identityResourceGroupName $outputFile $customRoleName

assignRole $identityId "Owner" $subscriptionId
assignRole $identityId "Managed Identity Operator" $subscriptionId
assignRole $identityId $customRoleName $subscriptionId
assignRole $windows365identityName "Reader" $subscriptionId
assignRole $currentAzureLoggedUser "DevCenter Dev Box User" $subscriptionId

Write-Host "Script completed."
