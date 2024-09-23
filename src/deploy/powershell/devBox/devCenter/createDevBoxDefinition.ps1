<#
.SYNOPSIS
    This script creates a DevBox definition in Azure DevCenter.

.DESCRIPTION
    This script takes eight parameters: the subscription ID, location, DevBox resource group name, DevCenter name, gallery name, image name, network connection name, and build image flag.
    It validates the input parameters, constructs necessary variables, creates a DevBox definition, and creates development pools and boxes.

.PARAMETER subscriptionId
    The Azure subscription ID.

.PARAMETER location
    The Azure location.

.PARAMETER devBoxResourceGroupName
    The name of the resource group for the DevBox.

.PARAMETER devCenterName
    The name of the DevCenter.

.PARAMETER galleryName
    The name of the image gallery.

.PARAMETER imageName
    The name of the image.

.PARAMETER networkConnectionName
    The name of the network connection.

.PARAMETER buildImage
    The flag indicating whether to build the image.

.EXAMPLE
    .\CreateDevBoxDefinition.ps1 -subscriptionId "12345678-1234-1234-1234-123456789012" -location "EastUS" -devBoxResourceGroupName "myResourceGroup" -devCenterName "myDevCenter" -galleryName "myGallery" -imageName "myImage" -networkConnectionName "myNetworkConnection" -buildImage "true"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$subscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [string]$devBoxResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$devCenterName,

    [Parameter(Mandatory = $true)]
    [string]$galleryName,

    [Parameter(Mandatory = $true)]
    [string]$imageName,

    [Parameter(Mandatory = $true)]
    [string]$networkConnectionName,

    [Parameter(Mandatory = $true)]
    [string]$buildImage
)

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\CreateDevBoxDefinition.ps1 -subscriptionId <subscriptionId> -location <location> -devBoxResourceGroupName <devBoxResourceGroupName> -devCenterName <devCenterName> -galleryName <galleryName> -imageName <imageName> -networkConnectionName <networkConnectionName> -buildImage <buildImage>"
    exit 1
}

# Function to generate a random name
function Generate-RandomName {
    $adjectives = @("Automated", "Continuous", "Integrated", "Scalable", "Efficient", "Resilient", "Reliable", "Secure", "Optimized", "Collaborative",
                    "Agile", "Adaptive", "Dynamic", "Flexible", "Innovative", "Proactive", "Robust", "Streamlined", "Unified", "Versatile",
                    "Responsive", "Compliant", "Consistent", "Effective", "Expandable", "Maintainable", "Portable", "Scalable", "Automated",
                    "Efficient", "Interoperable", "Modular", "Robust", "Streamlined", "Sustainable", "Unified", "Versatile", "Resilient", 
                    "Optimized", "Collaborative", "Agile", "Adaptive", "Dynamic", "Flexible", "Innovative", "Proactive", "Reliable")
    $terms = @("Developer", "Architect", "Engineer", "Coder", "Programmer", "Hacker", "Debugger", "Designer", "Analyst", "Tester",
               "SysAdmin", "DevOps", "ScrumMaster", "ProductOwner", "TechLead", "TeamLead", "Backend", "Frontend", "FullStack", "Database",
               "Administrator", "CloudSpecialist", "SRE", "NetworkEngineer", "SecurityAnalyst", "QAEngineer", "DataScientist", "AIEngineer", 
               "MachineLearning", "Consultant", "AutomationSpecialist", "BuildMaster", "ReleaseManager", "ProjectManager", "BusinessAnalyst",
               "SupportEngineer", "SystemArchitect", "IntegrationSpecialist", "SolutionArchitect", "TechSupport", "InfrastructureEngineer",
               "PlatformEngineer", "ServiceManager", "ITManager", "SoftwareConsultant", "CloudEngineer", "ITConsultant", "OperationsManager",
               "DevSecOps")
    $randomAdjective = $adjectives | Get-Random
    $randomTerm = $terms | Get-Random
    $randomNumber = Get-Random -Minimum 0 -Maximum 1000
    return "${randomAdjective}${randomTerm}${randomNumber}"
}

# Function to get the content before the hyphen
function Get-BeforeHyphen {
    param (
        [string]$inputString
    )
    return $inputString.Split('-')[0]
}

# Function to create development pools and boxes
function Create-DevPoolsAndDevBoxes {
    param (
        [string]$location,
        [string]$devBoxDefinitionName,
        [string]$networkConnectionName,
        [string]$poolName,
        [string]$devBoxResourceGroupName,
        [string]$devBoxName,
        [string]$devCenterName
    )

    $projects = @{
        "eShop" = "eShop"
    }

    foreach ($projectName in $projects.Keys) {
        # Creating DevBox Pools
        Write-Host "Creating DevBox Pools for $projectName..."
        .\devBox\devCenter\createDevBoxPools.ps1 -location $location -devBoxDefinitionName $devBoxDefinitionName -networkConnectionName $networkConnectionName -poolName $poolName -projectName $projectName -devBoxResourceGroupName $devBoxResourceGroupName
        Write-Host "DevBox Pools for $projectName created successfully."
    }
}

# Function to create a DevBox definition
function Create-DevBoxDefinition {
    param (
        [string]$subscriptionId,
        [string]$location,
        [string]$devBoxResourceGroupName,
        [string]$devCenterName,
        [string]$galleryName,
        [string]$imageName,
        [string]$networkConnectionName,
        [string]$buildImage
    )

    # Construct necessary variables
    if ($buildImage -eq "true") {
        $imageReferenceId = "/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/$galleryName/images/$imageName/versions/1.0.0"
    } else {
        $imageReferenceId = "/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/Default/images/$imageName"
    }

    $devBoxDefinitionName = "$(Generate-RandomName)-def"
    $poolName = "$(Get-BeforeHyphen $devBoxDefinitionName)-pool"
    $devBoxName = "$(Get-BeforeHyphen $devBoxDefinitionName)-devbox"

    # Display constructed variables
    Write-Host "Constructed variables:"
    Write-Host "imageReferenceId: $imageReferenceId"
    Write-Host "devBoxDefinitionName: $devBoxDefinitionName"
    Write-Host "networkConnectionName: $networkConnectionName"
    Write-Host "poolName: $poolName"
    Write-Host "devBoxName: $devBoxName"
    Write-Host "imageName: $imageName"

    # Create a DevBox definition
    Write-Host "Creating DevBox definition..."
    try {
        az devcenter admin devbox-definition create `
            --location $location `
            --image-reference id=$imageReferenceId `
            --os-storage-type "ssd_512gb" `
            --sku name="general_i_32c128gb512ssd_v2" `
            --name $devBoxDefinitionName `
            --dev-center-name $devCenterName `
            --resource-group $devBoxResourceGroupName
        Write-Host "DevBox definition created successfully."
    } catch {
        Write-Error "Error: Failed to create DevBox definition."
        exit 1
    }

    # Invoke the function to create development pools and boxes
    Create-DevPoolsAndDevBoxes -location $location -devBoxDefinitionName $devBoxDefinitionName -networkConnectionName $networkConnectionName -poolName $poolName -devBoxResourceGroupName $devBoxResourceGroupName -devBoxName $devBoxName -devCenterName $devCenterName
}

# Main script execution
if ($PSCmdlet.MyInvocation.BoundParameters.Count -ne 8) {
    Write-Error "Error: Invalid number of arguments."
    Show-Usage
}

Create-DevBoxDefinition -subscriptionId $subscriptionId -location $location -devBoxResourceGroupName $devBoxResourceGroupName -devCenterName $devCenterName -galleryName $galleryName -imageName $imageName -networkConnectionName $networkConnectionName -buildImage $buildImage