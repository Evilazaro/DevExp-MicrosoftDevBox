<#
.SYNOPSIS
    This script creates DevCenter projects in Azure.

.DESCRIPTION
    This script takes four parameters: the location, subscription ID, DevBox resource group name, and DevCenter name.
    It validates the input parameters, constructs necessary variables, and creates DevCenter projects using Azure CLI.

.PARAMETER location
    The Azure location where the DevCenter projects will be created.

.PARAMETER subscriptionId
    The Azure subscription ID.

.PARAMETER devBoxResourceGroupName
    The name of the resource group for the DevBox.

.PARAMETER devCenterName
    The name of the DevCenter.

.EXAMPLE
    .\CreateDevCenterProject.ps1 -location "EastUS" -subscriptionId "12345678-1234-1234-1234-123456789012" -devBoxResourceGroupName "myResourceGroup" -devCenterName "myDevCenter"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [string]$subscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$devBoxResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$devCenterName
)

# Function to display usage instructions
function Show-Usage {
    Write-Host "Usage: .\CreateDevCenterProject.ps1 -location <location> -subscriptionId <subscriptionId> -devBoxResourceGroupName <devBoxResourceGroupName> -devCenterName <devCenterName>"
    exit 1
}

# Function to validate the number of arguments passed to the script
function Validate-Arguments {
    param (
        [int]$argumentCount
    )

    if ($argumentCount -ne 4) {
        Write-Error "Error: Incorrect number of arguments."
        Show-Usage
    }
}

# Function to create DevCenter projects in Azure
function Create-DevCenterProjects {
    param (
        [string]$location,
        [string]$description,
        [string]$devCenterId,
        [string]$devBoxResourceGroupName,
        [string]$maxDevBoxesPerUser
    )

    $projects = @{
        "eShop" = "eShop"
    }

    foreach ($projectName in $projects.Keys) {
        Write-Host "Creating a new DevCenter admin project in Azure..."
        Write-Host "Location: $location"
        Write-Host "Dev Center ID: $devCenterId"
        Write-Host "Resource Group Name: $devBoxResourceGroupName"
        Write-Host "Description: $description"
        Write-Host "Project Name: $($projects[$projectName])"
        Write-Host "Max Dev Boxes Per User: $maxDevBoxesPerUser"

        try {
            az devcenter admin project create `
                --location $location `
                --description $description `
                --dev-center-id $devCenterId `
                --name $($projects[$projectName]) `
                --resource-group $devBoxResourceGroupName `
                --max-dev-boxes-per-user $maxDevBoxesPerUser `
                --tags  "division=petv2-Platform" `
                        "Environment=Prod" `
                        "offer=petv2-DevWorkstation-Service" `
                        "Team=Engineering" `
                        "solution=$($projects[$projectName])" `
                        "businessUnit=e-Commerce" | Out-Null

            Write-Host "DevCenter admin project '$($projects[$projectName])' has been created successfully!"
        } catch {
            Write-Error "Error: Failed to create DevCenter admin project '$($projects[$projectName])'."
            exit 2
        }
    }
}

# Main function to orchestrate the script execution
function Deploy-DevCenterProject {
    param (
        [string]$location,
        [string]$subscriptionId,
        [string]$devBoxResourceGroupName,
        [string]$devCenterName
    )

    Validate-Arguments -argumentCount $PSCmdlet.MyInvocation.BoundParameters.Count

    $description = "Sample .NET Core reference application, powered by Microsoft"
    $maxDevBoxesPerUser = "10"
    $devCenterId = "/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devCenters/$devCenterName"

    Create-DevCenterProjects -location $location -description $description -devCenterId $devCenterId -devBoxResourceGroupName $devBoxResourceGroupName -maxDevBoxesPerUser $maxDevBoxesPerUser
}

# Execute the main function with all script arguments
Deploy-DevCenterProject -location $location -subscriptionId $subscriptionId -devBoxResourceGroupName $devBoxResourceGroupName -devCenterName $devCenterName