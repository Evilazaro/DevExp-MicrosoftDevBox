# PowerShell script to generate deployment credentials

param (
    [string]$appName,
    [string]$displayName
)

# Function to validate input parameters
function Validate-Input {
    param (
        [string]$appName,
        [string]$displayName
    )

    if ([string]::IsNullOrEmpty($appName) -or [string]::IsNullOrEmpty($displayName)) {
        Write-Output "Error: Missing required parameters."
        Write-Output "Usage: Validate-Input -appName <appName> -displayName <displayName>"
        return 1
    }
}

# Function to generate deployment credentials
function Generate-DeploymentCredentials {
    param (
        [string]$appName,
        [string]$displayName
    )

    # Define the role and get the subscription ID
    $role = "Owner"
    $subscriptionId = az account show --query id --output tsv
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to retrieve subscription ID."
        return 1
    }

    # Create the service principal and capture the appId
    $ghSecretBody = az ad sp create-for-rbac --name $appName --display-name $displayName --role $role --scopes "/subscriptions/$subscriptionId" --json-auth --output json
    $appId = az ad sp list --display-name $displayName --query "[0].appId" -o tsv

    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to create service principal."
        return 1
    }

    Write-Output "Service principal credentials:"
    Write-Output $ghSecretBody

    # Create users and assign roles
    Create-UsersAndAssignRole -appId $appId

    # Create GitHub secret for Azure credentials
    Create-GitHubSecretAzureCredentials -ghSecretBody $ghSecretBody
}

# Function to create users and assign roles
function Create-UsersAndAssignRole {
    param (
        [string]$appId
    )

    Write-Output "Creating users and assigning roles..."

    # Execute the script to create users and assign roles
    .\Azure\createUsersAndAssignRole.ps1
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to create users and assign roles."
        return 1
    }

    Write-Output "Users created and roles assigned successfully."
}

# Function to create a GitHub secret for Azure credentials
function Create-GitHubSecretAzureCredentials {
    param (
        [string]$ghSecretBody
    )

    if ([string]::IsNullOrEmpty($ghSecretBody)) {
        Write-Output "Error: Missing required parameter."
        Write-Output "Usage: Create-GitHubSecretAzureCredentials -ghSecretBody <ghSecretBody>"
        return 1
    }

    Write-Output "Creating GitHub secret for Azure credentials..."

    # Execute the script to create the GitHub secret
    .\GitHub\createGitHubSecretAzureCredentials.ps1 $ghSecretBody
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to create GitHub secret for Azure credentials."
        return 1
    }

    Write-Output "GitHub secret for Azure credentials created successfully."
}

# Main script execution
Validate-Input -appName $appName -displayName $displayName
Generate-DeploymentCredentials -appName $appName -displayName $displayName