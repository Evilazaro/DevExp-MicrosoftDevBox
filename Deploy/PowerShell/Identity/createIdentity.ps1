<#
.SYNOPSIS
This script creates an identity on Microsoft Azure.

.DESCRIPTION
It expects three parameters in the exact order:
1. ResourceGroupName - The name of the resource group.
2. Location - The location of the resource group.
3. IdentityName - The name of the identity to create.
#>

param (
    [string]$ResourceGroupName,
    [string]$Location,
    [string]$IdentityName
)

function Show-Usage {
    Write-Output "Usage: $PSCommandPath -ResourceGroupName <resourceGroupName> -Location <location> -IdentityName <identityName>"
    Write-Output "Example: $PSCommandPath -ResourceGroupName myResourceGroup -Location EastUS -IdentityName myIdentity"
    exit 1
}

# Check if the correct number of arguments is provided, if not, display usage information and exit.
if (-not $ResourceGroupName -or -not $Location -or -not $IdentityName) {
    Write-Output "Error: Invalid number of arguments."
    Show-Usage
}

# Echoing the assignments.
Write-Output "Resource Group Name: $ResourceGroupName"
Write-Output "Location: $Location"
Write-Output "Identity Name: $IdentityName"

# Informing the user about the identity creation step.
Write-Output "Creating identity '$IdentityName' in resource group '$ResourceGroupName' located in '$Location'..."

# Executing the Azure CLI command to create an identity and storing the output in a variable.
$output = az identity create `
    --resource-group "$ResourceGroupName" `
    --name "$IdentityName" `
    --location "$Location" 2>&1

# Checking the exit status of the last command executed and echoing appropriate messages.
if ($LASTEXITCODE -eq 0) {
    Write-Output "Identity '$IdentityName' successfully created."
} else {
    Write-Output "Error occurred while creating identity '$IdentityName': $output"
    exit 1
}
