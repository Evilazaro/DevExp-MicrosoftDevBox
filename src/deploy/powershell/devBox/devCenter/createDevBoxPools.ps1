<#
.SYNOPSIS
    This script creates a DevCenter admin pool in Azure DevCenter.

.DESCRIPTION
    This script takes six parameters: the location, DevBox definition name, network connection name, pool name, project name, and DevBox resource group name.
    It validates the input parameters, assigns them to variables, and creates a DevCenter admin pool using Azure CLI.

.PARAMETER location
    The Azure location where the DevCenter admin pool will be created.

.PARAMETER devBoxDefinitionName
    The name of the DevBox definition.

.PARAMETER networkConnectionName
    The name of the network connection.

.PARAMETER poolName
    The name of the pool.

.PARAMETER projectName
    The name of the project.

.PARAMETER devBoxResourceGroupName
    The name of the resource group for the DevBox.

.EXAMPLE
    .\CreateDevBoxPools.ps1 -location "EastUS" -devBoxDefinitionName "myDevBoxDef" -networkConnectionName "myNetworkConnection" -poolName "myPool" -projectName "myProject" -devBoxResourceGroupName "myResourceGroup"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [string]$devBoxDefinitionName,

    [Parameter(Mandatory = $true)]
    [string]$networkConnectionName,

    [Parameter(Mandatory = $true)]
    [string]$poolName,

    [Parameter(Mandatory = $true)]
    [string]$projectName,

    [Parameter(Mandatory = $true)]
    [string]$devBoxResourceGroupName
)

# Function to display usage instructions
function Show-Usage {
    Write-Host "Usage: .\CreateDevBoxPools.ps1 -location <location> -devBoxDefinitionName <devBoxDefinitionName> -networkConnectionName <networkConnectionName> -poolName <poolName> -projectName <projectName> -devBoxResourceGroupName <devBoxResourceGroupName>"
    exit 1
}

# Function to validate the number of arguments passed to the script
function Validate-Arguments {
    param (
        [int]$argumentCount
    )

    if ($argumentCount -ne 6) {
        Write-Error "Error: Incorrect number of arguments."
        Show-Usage
    }
}

# Function to create a DevCenter admin pool
function Create-DevCenterAdminPool {
    param (
        [string]$location,
        [string]$devBoxDefinitionName,
        [string]$networkConnectionName,
        [string]$poolName,
        [string]$projectName,
        [string]$devBoxResourceGroupName
    )

    Write-Host "Creating DevCenter admin pool with the following parameters:"
    Write-Host "Location: $location"
    Write-Host "DevBox Definition Name: $devBoxDefinitionName"
    Write-Host "Network Connection Name: $networkConnectionName"
    Write-Host "Pool Name: $poolName"
    Write-Host "Project Name: $projectName"
    Write-Host "Resource Group: $devBoxResourceGroupName"

    try {
        az devcenter admin pool create `
            --location $location `
            --devbox-definition-name $devBoxDefinitionName `
            --network-connection-name $networkConnectionName `
            --pool-name $poolName `
            --project-name $projectName `
            --resource-group $devBoxResourceGroupName `
            --local-administrator "Enabled" `
            --tags "Division=petv2-Platform" `
                   "Environment=Prod" `
                   "Offer=petv2-DevWorkstation-Service" `
                   "Team=Engineering" `
                   "Solution=$projectName" `
                   "BusinessUnit=e-Commerce" | Out-Null

        Write-Host "DevCenter admin pool created successfully."
    } catch {
        Write-Error "Error: Failed to create DevCenter admin pool. Please check the parameters and try again."
        exit 1
    }
}

# Main script execution
function Create-DevBoxPools {
    Validate-Arguments -argumentCount $PSCmdlet.MyInvocation.BoundParameters.Count
    Create-DevCenterAdminPool -location $location -devBoxDefinitionName $devBoxDefinitionName -networkConnectionName $networkConnectionName -poolName $poolName -projectName $projectName -devBoxResourceGroupName $devBoxResourceGroupName
}

# Execute the main function with all script arguments
Create-DevBoxPools -location $location -devBoxDefinitionName $devBoxDefinitionName -networkConnectionName $networkConnectionName -poolName $poolName -projectName $projectName -devBoxResourceGroupName $devBoxResourceGroupName