# PowerShell script to create user assignments and assign roles

# Get the current subscription ID
$subscriptionId = (az account show --query id -o tsv)

# Function to assign a role to a user or service principal
function Assign-Role {
    param (
        [string]$userIdentityId,
        [string]$roleName,
        [string]$idType
    )

    # Check if required parameters are provided
    if ([string]::IsNullOrEmpty($userIdentityId) -or [string]::IsNullOrEmpty($roleName) -or [string]::IsNullOrEmpty($idType)) {
        Write-Output "Error: Missing required parameters."
        Write-Output "Usage: Assign-Role -userIdentityId <userIdentityId> -roleName <roleName> -idType <idType>"
        return 1
    }

    Write-Output "Assigning '$roleName' role to identityId $userIdentityId..."

    # Attempt to assign the role
    $result = az role assignment create --assignee-object-id $userIdentityId --assignee-principal-type $idType --role $roleName --scope /subscriptions/$subscriptionId

    if ($result) {
        Write-Output "Role '$roleName' assigned successfully."
    } else {
        Write-Output "Error: Failed to assign role '$roleName' to identityId $userIdentityId."
        return 2
    }
}

# Function to create user assignments and assign roles
function Create-UserAssignments {
    # Get the current signed-in user's object ID
    $currentUser = az ad signed-in-user show --query id -o tsv

    if (-not $currentUser) {
        Write-Output "Error: Failed to retrieve current signed-in user's object ID."
        return 1
    }

    Write-Output "Creating user assignments and assigning roles for currentUser: $currentUser"

    Assign-Role -userIdentityId $currentUser -roleName "DevCenter Dev Box User" -idType "User"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to assign role 'DevCenter Dev Box User' to current user with object ID: $currentUser"
        return 1
    }

    Assign-Role -userIdentityId $currentUser -roleName "DevCenter Project Admin" -idType "User"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to assign role 'DevCenter Project Admin' to current user with object ID: $currentUser"
        return 1
    }

    Assign-Role -userIdentityId $currentUser -roleName "Deployment Environments Reader" -idType "User"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to assign role 'Deployment Environments Reader' to current user with object ID: $currentUser"
        return 1
    }

    Assign-Role -userIdentityId $currentUser -roleName "Deployment Environments User" -idType "User"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to assign role 'Deployment Environments User' to current user with object ID: $currentUser"
        return 1
    }

    Write-Output "User assignments and role assignments completed successfully for currentUser: $currentUser"
}

# Main script execution
Create-UserAssignments