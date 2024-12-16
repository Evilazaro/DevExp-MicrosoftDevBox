# PowerShell script to delete user assignments and roles

# Get the current subscription ID
$subscriptionId = (az account show --query id -o tsv)

# Function to delete user assignments and roles
function Delete-UserAssignments {
    # Get the current signed-in user's object ID
    $currentUser = az ad signed-in-user show --query id -o tsv
    if (-not $currentUser) {
        Write-Output "Error: Failed to retrieve current signed-in user's object ID."
        return 1
    }

    Write-Output "Deleting user assignments and roles for currentUser: $currentUser"
        
    # Remove roles from the service principal and current user
    Remove-Role -userIdentityId $currentUser -roleName "DevCenter Project Admin" -idType "ServicePrincipal"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to remove role 'DevCenter Project Admin' from service principal with currentUser: $currentUser"
        return 1
    }

    Remove-Role -userIdentityId $currentUser -roleName "DevCenter Dev Box User" -idType "User"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to remove role 'DevCenter Dev Box User' from current user with object ID: $currentUser"
        return 1
    }

    Write-Output "User assignments and role removals completed successfully for currentUser: $currentUser"

    Remove-Role -userIdentityId $currentUser -roleName "ContosoDevCenterDevBoxRole" -idType "User"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to remove role 'ContosoDevCenterDevBoxRole' from current user with object ID: $currentUser"
        return 1
    }

    Write-Output "User assignments and role removals completed successfully for currentUser: $currentUser"
}

# Function to remove a role from a user or service principal
function Remove-Role {
    param (
        [string]$userIdentityId,
        [string]$roleName,
        [string]$idType
    )

    # Check if required parameters are provided
    if ([string]::IsNullOrEmpty($userIdentityId) -or [string]::IsNullOrEmpty($roleName) -or [string]::IsNullOrEmpty($idType)) {
        Write-Output "Error: Missing required parameters."
        Write-Output "Usage: Remove-Role -userIdentityId <userIdentityId> -roleName <roleName> -idType <idType>"
        return 1
    }

    Write-Output "Removing '$roleName' role from identityId $userIdentityId..."

    # Attempt to remove the role
    $result = az role assignment delete --assignee $userIdentityId --role $roleName --scope /subscriptions/$subscriptionId
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to remove role '$roleName' from identityId $userIdentityId."
        return 2
    }

    Write-Output "Role '$roleName' removed successfully."
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

    $currentUser = az ad sp list --display-name $appDisplayName --query "[0].currentUser" -o tsv
}

# Main script execution
Validate-Input -appDisplayName $appDisplayName
Delete-UserAssignments