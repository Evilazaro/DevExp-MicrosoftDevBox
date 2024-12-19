# PowerShell script to delete GitHub secret for Azure credentials

param (
    [string]$ghSecretName
)

# Function to delete a GitHub secret
function Delete-GhSecret {
    param (
        [string]$ghSecretName
    )

    # Check if required parameter is provided
    if ([string]::IsNullOrEmpty($ghSecretName)) {
        Write-Output "Error: Missing required parameter."
        Write-Output "Usage: Delete-GhSecret -ghSecretName <ghSecretName>"
        return 1
    }

    Write-Output "Deleting GitHub secret: $ghSecretName"

    # Delete the GitHub secret
    gh secret remove $ghSecretName
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to delete GitHub secret: $ghSecretName"
        return 1
    }

    Write-Output "GitHub secret: $ghSecretName deleted successfully."
}

# Function to validate input parameters
function Validate-Input {
    param (
        [string]$ghSecretName
    )

    # Check if required parameters are provided
    if ([string]::IsNullOrEmpty($ghSecretName)) {
        Write-Output "Error: Missing required parameters."
        Write-Output "Usage: Validate-Input -ghSecretName <ghSecretName>"
        return 1
    }
}

# Function to log in to GitHub using the GitHub CLI
function Login-ToGitHub {
    Write-Output "Logging in to GitHub using GitHub CLI..."

    # Attempt to log in to GitHub
    gh auth login
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to log in to GitHub."
        return 1
    }

    Write-Output "Successfully logged in to GitHub."
}

# Main script execution
Validate-Input -ghSecretName $ghSecretName
if ($LASTEXITCODE -eq 0) {
    Login-ToGitHub
    if ($LASTEXITCODE -eq 0) {
        Delete-GhSecret -ghSecretName $ghSecretName
    }
}