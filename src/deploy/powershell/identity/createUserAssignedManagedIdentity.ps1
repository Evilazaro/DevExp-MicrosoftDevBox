#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script to create a user-assigned managed identity and assign roles.

.DESCRIPTION
    This script creates a user-assigned managed identity in a specified resource group and location,
    creates a custom role, and assigns various roles to the identity.

.PARAMETER IdentityResourceGroupName
    The name of the resource group where the identity will be created.

.PARAMETER SubscriptionId
    The Azure subscription ID.

.PARAMETER IdentityName
    The name of the identity to be created.

.PARAMETER CustomRoleName
    The name of the custom role to be created and assigned.

.EXAMPLE
    .\createUserAssignedManagedIdentity.ps1 -IdentityResourceGroupName "myResourceGroup" -SubscriptionId "mySubscriptionId" -IdentityName "myIdentity" -CustomRoleName "myCustomRole"
#>

# Constants
$Branch = "main"
$OutputFilePath = "../downloadedTempTemplates/identity/roleImage.json"
$TemplateUrl = "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$Branch/src/deploy/ARMTemplates/identity/roleImage.json"

# Function to display usage information
function Display-Usage {
    Write-Host "Usage: .\createUserAssignedManagedIdentity.ps1 -IdentityResourceGroupName <resourceGroupName> -SubscriptionId <subscriptionId> -IdentityName <identityName> -CustomRoleName <customRoleName>"
    exit 1
}

# Function to validate input parameters
function Validate-Parameters {
    param (
        [string]$IdentityResourceGroupName,
        [string]$SubscriptionId,
        [string]$IdentityName,
        [string]$CustomRoleName
    )

    if (-not $IdentityResourceGroupName -or -not $SubscriptionId -or -not $IdentityName -or -not $CustomRoleName) {
        Write-Host "Error: Missing required parameters."
        Display-Usage
    }
}

# Function to create a custom role
function Create-CustomRole {
    param (
        [string]$SubscriptionId,
        [string]$ResourceGroupName,
        [string]$OutputFilePath,
        [string]$RoleName
    )

    Write-Host "Starting custom role creation..."
    Write-Host "Downloading image template..."

    try {
        Invoke-WebRequest -Uri $TemplateUrl -OutFile $OutputFilePath -Headers @{"Cache-Control"="no-cache"; "Pragma"="no-cache"}
        Write-Host "Template downloaded to $OutputFilePath."
        Write-Host "Role Name: $RoleName"

        Write-Host "Updating placeholders in the template..."
        (Get-Content $OutputFilePath) -replace '<subscriptionId>', $SubscriptionId -replace '<rgName>', $ResourceGroupName -replace '<roleName>', $RoleName | Set-Content $OutputFilePath

        az role definition create --role-definition $OutputFilePath | Out-Null
        Write-Host "Custom role creation completed."
    }
    catch {
        Write-Host "Error: Failed to create custom role. $_"
        exit 1
    }
}

# Function to assign a role to an identity
function Assign-Role {
    param (
        [string]$Id,
        [string]$RoleName,
        [string]$SubscriptionId,
        [string]$IdType
    )

    Write-Host "Assigning '$RoleName' role to ID $Id..."

    try {
        az role assignment create --assignee-object-id $Id --assignee-principal-type $IdType --role $RoleName --scope /subscriptions/$SubscriptionId | Out-Null
        Write-Host "Role '$RoleName' assigned."
    }
    catch {
        Write-Host "Error: Failed to assign role '$RoleName'. $_"
        exit 1
    }
}

# Main script execution
param (
    [Parameter(Mandatory=$true)]
    [string]$IdentityResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory=$true)]
    [string]$IdentityName,

    [Parameter(Mandatory=$true)]
    [string]$CustomRoleName
)

Write-Host "Script started."

Validate-Parameters -IdentityResourceGroupName $IdentityResourceGroupName -SubscriptionId $SubscriptionId -IdentityName $IdentityName -CustomRoleName $CustomRoleName

$currentUser = az account show --query user.name -o tsv
$currentAzureUserId = az ad user show --id $currentUser --query id -o tsv
$identityId = az identity show --name $IdentityName --resource-group $IdentityResourceGroupName --query principalId -o tsv

Create-CustomRole -SubscriptionId $SubscriptionId -ResourceGroupName $IdentityResourceGroupName -OutputFilePath $OutputFilePath -RoleName $CustomRoleName

$roles = @(
    "Virtual Machine Contributor",
    "Desktop Virtualization Contributor",
    "Desktop Virtualization Virtual Machine Contributor",
    "Desktop Virtualization Workspace Contributor",
    "Compute Gallery Sharing Admin",
    "Virtual Machine Local User Login",
    "Managed Identity Operator",
    $CustomRoleName
)

foreach ($role in $roles) {
    Assign-Role -Id $identityId -RoleName $role -SubscriptionId $SubscriptionId -IdType "ServicePrincipal"
}

Assign-Role -Id $currentAzureUserId -RoleName "DevCenter Dev Box User" -SubscriptionId $SubscriptionId -IdType "User"

Write-Host "Script completed."