# PowerShell script to set up deployment credentials

# Define variables
$appName = "eShop"
$displayName = "PetDx GitHub Actions Enterprise App"

# Function to set up deployment credentials
function Setup {
    param (
        [string]$appName,
        [string]$displayName
    )

    Write-Output "Setting up deployment credentials..."

    # Execute the script to generate deployment credentials
    .\Azure\generateDeploymentCredentials.ps1 -appName $appName -displayName $displayName
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to set up deployment credentials."
        return 1
    }

    Write-Output "Deployment credentials set up successfully."
}

# Main script execution
Clear-Host
Setup -appName $appName -displayName $displayName