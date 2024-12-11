# PowerShell script to create GitHub secret for Azure credentials

param (
    [string]$ghSecretBody
)

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

# Function to set up GitHub secret authentication
function Setup-GitHubSecretAuthentication {
    param (
        [string]$ghSecretBody
    )

    $ghSecretName = "AZURE_CREDENTIALS"
    
    # Check if required parameter is provided
    if ([string]::IsNullOrEmpty($ghSecretBody)) {
        Write-Output "Error: Missing required parameter."
        Write-Output "Usage: Setup-GitHubSecretAuthentication -ghSecretBody <ghSecretBody>"
        return 1
    }

    Write-Output "Setting up GitHub secret authentication..."

    # Log in to GitHub
    Login-ToGitHub
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to log in to GitHub."
        return 1
    }

    # Set the GitHub secret
    gh secret set $ghSecretName --body $ghSecretBody
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to set GitHub secret: $ghSecretName"
        return 1
    }

    Write-Output "GitHub secret: $ghSecretName set successfully."
    Write-Output "GitHub secret body: $ghSecretBody"
}

# Function to validate input parameters
function Validate-Input {
    param (
        [string]$ghSecretBody
    )

    # Check if required parameters are provided
    if ([string]::IsNullOrEmpty($ghSecretBody)) {
        Write-Output "Error: Missing required parameters."
        Write-Output "Usage: Validate-Input -ghSecretBody <ghSecretBody>"
        return 1
    }
}

# Main script execution
Validate-Input -ghSecretBody $ghSecretBody
Setup-GitHubSecretAuthentication -ghSecretBody $ghSecretBody