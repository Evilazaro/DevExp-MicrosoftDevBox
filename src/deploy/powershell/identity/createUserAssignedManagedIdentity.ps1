<#
.SYNOPSIS
    This script creates a user-assigned managed identity and assigns a custom role in Azure.

.DESCRIPTION
    This script takes five parameters: the resource group name, the subscription ID, the identity name, the custom role name, and the location.
    It creates a user-assigned managed identity, downloads a role definition template, updates the template with the provided parameters, creates the custom role, and assigns the role to the identity.

.PARAMETER identityResourceGroupName
    The name of the resource group where the identity will be created.

.PARAMETER subscriptionId
    The Azure subscription ID.

.PARAMETER identityName
    The name of the identity to be created.

.PARAMETER customRoleName
    The name of the custom role to be created.

.PARAMETER location
    The Azure location where the identity will be created.

.EXAMPLE
    .\CreateUserAssignedManagedIdentity.ps1 -identityResourceGroupName "myResourceGroup" -subscriptionId "12345678-1234-1234-1234-123456789012" -identityName "myIdentity" -customRoleName "myCustomRole" -location "EastUS"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$identityResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$subscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$identityName,

    [Parameter(Mandatory = $true)]
    [string]$customRoleName,

    [Parameter(Mandatory = $true)]
    [string]$location
)

# Constants
$branch = "main"
$outputFilePath = "../downloadedTempTemplates/identity/roleImage.json"
$templateUrl = "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/identity/roleImage.json"

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\CreateUserAssignedManagedIdentity.ps1 -identityResourceGroupName <identityResourceGroupName> -subscriptionId <subscriptionId> -identityName <identityName> -customRoleName <customRoleName> -location <location>"
    Write-Host "Example: .\CreateUserAssignedManagedIdentity.ps1 -identityResourceGroupName 'myResourceGroup' -subscriptionId '12345678-1234-1234-1234-123456789012' -identityName 'myIdentity' -customRoleName 'myCustomRole' -location 'EastUS'"
    exit 1
}

# Function to create a custom role using a template
function Create-CustomRole {
    Write-Host "Starting custom role creation..."
    Write-Host "Downloading image template..."

    try {
        Invoke-WebRequest -Uri $templateUrl -OutFile $outputFilePath -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" }
        Write-Host "Template downloaded to $outputFilePath."
    } catch {
        Write-Error "Error: Failed to download the image template."
        exit 3
    }

    Write-Host "Role Name: $customRoleName"
    Write-Host "Updating placeholders in the template..."

    try {
        (Get-Content $outputFilePath) -replace '<subscriptionId>', $subscriptionId -replace '<rgName>', $identityResourceGroupName -replace '<roleName>', $customRoleName | Set-Content $outputFilePath
        Write-Host "Placeholders updated successfully."
    } catch {
        Write-Error "Error updating placeholders."
        exit 4
    }

    try {
        az role definition create --role-definition $outputFilePath
        Write-Host "Custom role created successfully."
    } catch {
        Write-Error "Error creating custom role."
        exit 5
    }

    while ((az role definition list --name $customRoleName) -eq "[]") {
        Write-Host "Waiting for the role to be created..."
        Start-Sleep -Seconds 20
    }

    Write-Host "Custom role creation completed."
}

# Function to assign a role to an identity
function Assign-Role {
    param (
        [string]$userIdentityId,
        [string]$roleName,
        [string]$idType
    )

    Write-Host "Assigning '$roleName' role to identityId $userIdentityId..."

    try {
        az role assignment create --assignee-object-id $userIdentityId --assignee-principal-type $idType --role $roleName --scope /subscriptions/$subscriptionId
        Write-Host "Role '$roleName' assigned."
    } catch {
        Write-Error "Error assigning '$roleName'."
        exit 2
    }
}

# Main script execution
function Create-UserAssignedManagedIdentity {
    Write-Host "Creating identity '$identityName' in resource group '$identityResourceGroupName' located in '$location'..."

    $currentUser = az ad signed-in-user show --query id -o tsv
    $identityId = az identity show --name $identityName --resource-group $identityResourceGroupName --query principalId -o tsv

    Create-CustomRole

    # Assign roles
    Assign-Role -userIdentityId $identityId -roleName $customRoleName -idType "ServicePrincipal"
    Assign-Role -userIdentityId $currentUser -roleName "DevCenter Dev Box User" -idType "User"
}

if ($PSCmdlet.MyInvocation.BoundParameters.Count -ne 5) {
    Write-Error "Error: Invalid number of arguments."
    Show-Usage
}

Create-UserAssignedManagedIdentity