<#
.SYNOPSIS
    This script creates an Azure identity in a specified resource group and location.

.DESCRIPTION
    This script takes three parameters: the resource group name, the location, and the identity name.
    It creates an Azure identity in the specified resource group and location.

.PARAMETER identityResourceGroupName
    The name of the resource group where the identity will be created.

.PARAMETER location
    The Azure location where the identity will be created.

.PARAMETER identityName
    The name of the identity to be created.

.EXAMPLE
    .\createIdentity.ps1 -identityResourceGroupName "myResourceGroup" -location "EastUS" -identityName "myIdentity"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$identityResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [string]$identityName
)

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\createIdentity.ps1 -identityResourceGroupName <identityResourceGroupName> -location <location> -identityName <identityName>"
    Write-Host "Example: .\createIdentity.ps1 -identityResourceGroupName 'myResourceGroup' -location 'EastUS' -identityName 'myIdentity'"
    exit 1
}

# Function to create an Azure identity
function Create-AzureIdentity {
    param (
        [string]$identityResourceGroupName,
        [string]$location,
        [string]$identityName
    )

    Write-Host "Creating identity '$identityName' in resource group '$identityResourceGroupName' located in '$location'..."

    try {
        $output = az identity create --resource-group $identityResourceGroupName --name $identityName --location $location -o json
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Identity '$identityName' successfully created."
        } else {
            Write-Error "Error occurred while creating identity '$identityName': $output"
            exit 1
        }
    } catch {
        Write-Error "Exception occurred: $_"
        exit 1
    }
}

# Main script execution
if ($PSCmdlet.MyInvocation.BoundParameters.Count -ne 3) {
    Write-Error "Error: Invalid number of arguments."
    Show-Usage
}

Create-AzureIdentity -identityResourceGroupName $identityResourceGroupName -location $location -identityName $identityName