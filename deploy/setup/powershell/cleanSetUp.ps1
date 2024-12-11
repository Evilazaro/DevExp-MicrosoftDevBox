# PowerShell script to clean up the setup by deleting users, credentials, and GitHub secrets

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
$ErrorActionPreference = "Stop"
$WarningPreference = "Stop"

$appDisplayName = "ContosoDevEx GitHub Actions Enterprise App"
$ghSecretName = "AZURE_CREDENTIALS"

# Function to clean up the setup by deleting users, credentials, and GitHub secrets
function Clean-SetUp {
    param (
        [string]$appDisplayName,
        [string]$ghSecretName
    )

    # Check if required parameters are provided
    if ([string]::IsNullOrEmpty($appDisplayName) -or [string]::IsNullOrEmpty($ghSecretName)) {
        Write-Output "Error: Missing required parameters."
        Write-Output "Usage: Clean-SetUp -appDisplayName <appDisplayName> -ghSecretName <ghSecretName>"
        return 1
    }

    Write-Output "Starting cleanup process for appDisplayName: $appDisplayName and ghSecretName: $ghSecretName"

    # Delete users and assigned roles
    Write-Output "Deleting users and assigned roles..."
    .\Azure\deleteUsersAndAssignedRoles.ps1 $appDisplayName
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to delete users and assigned roles for appDisplayName: $appDisplayName"
        return 1
    }

    # Delete deployment credentials
    Write-Output "Deleting deployment credentials..."
    .\Azure\deleteDeploymentCredentials.ps1 $appDisplayName
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to delete deployment credentials for appDisplayName: $appDisplayName"
        return 1
    }

    # Delete GitHub secret for Azure credentials
    Write-Output "Deleting GitHub secret for Azure credentials..."
    .\GitHub\deleteGitHubSecretAzureCredentials.ps1 $ghSecretName
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to delete GitHub secret for Azure credentials: $ghSecretName"
        return 1
    }

    Write-Output "Cleanup process completed successfully for appDisplayName: $appDisplayName and ghSecretName: $ghSecretName"
}

# Main script execution
Clear-Host
Clean-SetUp -appDisplayName $appDisplayName -ghSecretName $ghSecretName