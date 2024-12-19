# PowerShell script to delete deployment credentials

param (
    [string]$appDisplayName
)

# Function to delete deployment credentials
function Delete-DeploymentCredentials {
    param (
        [string]$appDisplayName
    )

    # Get the application ID using the display name
    $appId = az ad app list --display-name $appDisplayName --query "[0].appId" -o tsv

    if (-not $appId) {
        Write-Output "Error: Application with display name '$appDisplayName' not found."
        return 1
    }

    # Delete the service principal
    Write-Output "Deleting service principal with appId: $appId"
    $spDeleteResult = az ad sp delete --id $appId
    if ($spDeleteResult -ne $null) {
        Write-Output "Error: Failed to delete service principal."
        return 1
    }

    # Delete the application registration
    Write-Output "Deleting application registration with appId: $appId"
    $appDeleteResult = az ad app delete --id $appId
    if ($appDeleteResult -ne $null) {
        Write-Output "Error: Failed to delete application registration."
        return 1
    }

    Write-Output "Service principal and App Registration deleted successfully."
}

# Function to validate input parameters
function Validate-Input {
    param (
        [string]$appDisplayName
    )

    if ([string]::IsNullOrEmpty($appDisplayName)) {
        Write-Output "Error: Missing required parameter."
        Write-Output "Usage: .\deleteDeploymentCredentials.ps1 -appDisplayName <appDisplayName>"
        return 1
    }
}

# Main script execution
Validate-Input -appDisplayName $appDisplayName
Delete-DeploymentCredentials -appDisplayName $appDisplayName

