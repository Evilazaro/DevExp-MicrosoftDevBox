# Azure Resource Group Names Constants
param (
    [Parameter(Mandatory = $true)]
    [string]$subscriptionName,
    [Parameter(Mandatory = $false)]
    [bool]$buildImage,
    [Parameter(Mandatory = $false)]
    [bool]$scriptDemo
)

# PowerShell script to deploy to Azure

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Output "Deploying to Azure"

# Constants Parameters
$branch = "main"
$location = "WestUS3"

$devBoxResourceGroupName = "petv2DevBox-rg"
$imageGalleryResourceGroupName = "petv2ImageGallery-rg"
$identityResourceGroupName = "petv2IdentityDevBox-rg"
$networkResourceGroupName = "petv2NetworkConnectivity-rg"
$managementResourceGroupName = "petv2DevBoxManagement-rg"

# Identity Parameters Constants
$identityName = "petv2DevBoxImgBldId"
$customRoleName = "petv2BuilderRole"

# Image and DevCenter Parameters Constants
$imageGalleryName = "petv2ImageGallery"
$frontEndImageName = "frontEndVm"
$backEndImageName = "backEndVm"
$devCenterName = "petv2DevCenter"

# Network Parameters Constants
$vnetName = "petv2Vnet"
$subNetName = "petv2SubNet"
$networkConnectionName = "devBoxNetworkConnection"

# Function to log in to Azure
function Azure-Login {
    param (
        [string]$subscriptionName
    )

    if ([string]::IsNullOrEmpty($subscriptionName)) {
        Write-Error "Error: Subscription name is missing!"
        Write-Output "Usage: azureLogin -subscriptionName <subscriptionName>"
        return 1
    }

    Write-Output "Attempting to login to Azure subscription: $subscriptionName"

    $scriptPath = "./identity/login.ps1"
    if (-not (Test-Path $scriptPath -PathType Leaf)) {
        Write-Error "Error: The login script $scriptPath does not exist or is not executable."
        return 1
    }

    & $scriptPath -subscriptionName $subscriptionName
    if ($LASTEXITCODE -eq 0) {
        Write-Output "Successfully logged in to $subscriptionName."
    } else {
        Write-Error "Failed to log in to $subscriptionName."
        return 1
    }
}

# Function to create an Azure resource group
function Create-ResourceGroup {
    param (
        [string]$resourceGroupName,
        [string]$location
    )

    if ([string]::IsNullOrEmpty($resourceGroupName) -or [string]::IsNullOrEmpty($location)) {
        Write-Error "Error: Missing required parameters."
        Write-Output "Usage: Create-ResourceGroup -resourceGroupName <resourceGroupName> -location <location>"
        return 1
    }

    Write-Output "Creating Azure Resource Group: $resourceGroupName in $location"

    $result = az group create --name $resourceGroupName --location $location --tags "division=petv2-Platform" "Environment=Prod" "offer=petv2-DevWorkstation-Service" "Team=Engineering" "solution=ContosoFabricDevWorkstation"
    if ($result) {
        Write-Output "Resource group '$resourceGroupName' created successfully."
    } else {
        Write-Error "Error: Failed to create resource group '$resourceGroupName'."
        return 1
    }
}

# Function to deploy resources for the organization
function Deploy-ResourcesOrganization {
    Create-ResourceGroup -resourceGroupName $devBoxResourceGroupName
    Create-ResourceGroup -resourceGroupName $imageGalleryResourceGroupName
    Create-ResourceGroup -resourceGroupName $identityResourceGroupName
    Create-ResourceGroup -resourceGroupName $networkResourceGroupName
    Create-ResourceGroup -resourceGroupName $managementResourceGroupName

    Demo-Script
}

# Function to create an identity
function Create-Identity {
    param (
        [string]$subscriptionId
    )

    if ([string]::IsNullOrEmpty($identityName) -or [string]::IsNullOrEmpty($identityResourceGroupName) -or [string]::IsNullOrEmpty($subscriptionId) -or [string]::IsNullOrEmpty($customRoleName) -or [string]::IsNullOrEmpty($location)) {
        Write-Error "Error: Missing required parameters."
        Write-Output "Usage: Create-Identity -subscriptionId <subscriptionId>"
        return 1
    }

    Write-Output "Creating identity..."
    if (-not (./identity/createIdentity.ps1 -resourceGroupName $identityResourceGroupName -location $location -identityName $identityName)) {
        Write-Error "Error: Failed to create identity."
        return 1
    }

    Write-Output "Registering features..."
    if (-not (./identity/registerFeatures.ps1)) {
        Write-Error "Error: Failed to register features."
        return 1
    }

    Write-Output "Creating user-assigned managed identity..."
    $subscriptionId = (az account show --query id --output tsv)

    Write-Output "Subscription ID: $subscriptionId"

    if (-not (./identity/createUserAssignedManagedIdentity.ps1 -resourceGroupName $identityResourceGroupName -subscriptionId $subscriptionId -identityName $identityName -customRoleName $customRoleName -location $location)) {
        Write-Error "Error: Failed to create user-assigned managed identity."
        return 1
    }

    Write-Output "Identity and features successfully created and registered."

    Demo-Script
}

# Function to deploy a virtual network
function Deploy-Network {
    if (-not (Test-Path "./network/deployVnet.ps1")) {
        Write-Error "Error: deployVnet.ps1 script not found."
        return 1
    }

    if (-not (Test-Path "./network/createNetworkConnection.ps1")) {
        Write-Error "Error: createNetworkConnection.ps1 script not found."
        return 1
    }

    Write-Output "Deploying virtual network..."
    if (-not (./network/deployVnet.ps1 -resourceGroupName $networkResourceGroupName -location $location -vnetName $vnetName -subNetName $subNetName)) {
        Write-Error "Error: Failed to deploy virtual network."
        return 1
    }

    Write-Output "Creating network connection..."
    if (-not (./network/createNetworkConnection.ps1 -location $location -resourceGroupName $networkResourceGroupName -vnetName $vnetName -subNetName $subNetName -networkConnectionName $networkConnectionName)) {
        Write-Error "Error: Failed to create network connection."
        return 1
    }

    Write-Output "Virtual network and network connection deployed successfully."

    Demo-Script
}

# Function to deploy a compute gallery
function Deploy-ComputeGallery {
    param (
        [string]$imageGalleryName,
        [string]$imageGalleryResourceGroupName
    )

    if ([string]::IsNullOrEmpty($imageGalleryName) -or [string]::IsNullOrEmpty($imageGalleryResourceGroupName)) {
        Write-Error "Error: Missing required arguments."
        Write-Output "Usage: Deploy-ComputeGallery -imageGalleryName <imageGalleryName> -imageGalleryResourceGroupName <imageGalleryResourceGroupName>"
        return 1
    }

    $deployScript = "./devBox/computeGallery/deployComputeGallery.ps1"
    if (-not (Test-Path $deployScript)) {
        Write-Error "Error: Deployment script not found at $deployScript"
        return 1
    }

    Write-Output "Deploying Compute Gallery: $imageGalleryName in Resource Group: $imageGalleryResourceGroupName"
    & $deployScript -imageGalleryName $imageGalleryName -location $location -resourceGroupName $imageGalleryResourceGroupName

    Demo-Script
}

# Function to deploy a Dev Center
function Deploy-DevCenter {
    if ([string]::IsNullOrEmpty($devCenterName) -or [string]::IsNullOrEmpty($networkConnectionName) -or [string]::IsNullOrEmpty($imageGalleryName) -or [string]::IsNullOrEmpty($location) -or [string]::IsNullOrEmpty($identityName) -or [string]::IsNullOrEmpty($devBoxResourceGroupName) -or [string]::IsNullOrEmpty($networkResourceGroupName) -or [string]::IsNullOrEmpty($identityResourceGroupName) -or [string]::IsNullOrEmpty($imageGalleryResourceGroupName)) {
        Write-Error "Error: Missing required parameters."
        return 1
    }

    Write-Output "Deploying Dev Center: $devCenterName"
    & ./devBox/devCenter/deployDevCenter.ps1 -devCenterName $devCenterName -networkConnectionName $networkConnectionName -imageGalleryName $imageGalleryName -location $location -identityName $identityName -devBoxResourceGroupName $devBoxResourceGroupName -networkResourceGroupName $networkResourceGroupName -identityResourceGroupName $identityResourceGroupName -imageGalleryResourceGroupName $imageGalleryResourceGroupName

    Create-DevCenterProject
}

# Function to create a Dev Center project
function Create-DevCenterProject {
    param (
        [string]$location,
        [string]$subscriptionId,
        [string]$devBoxResourceGroupName,
        [string]$devCenterName
    )

    if ([string]::IsNullOrEmpty($location) -or [string]::IsNullOrEmpty($subscriptionId) -or [string]::IsNullOrEmpty($devBoxResourceGroupName) -or [string]::IsNullOrEmpty($devCenterName)) {
        Write-Error "Error: Missing required parameters."
        Write-Output "Usage: Create-DevCenterProject -location <location> -subscriptionId <subscriptionId> -devBoxResourceGroupName <devBoxResourceGroupName> -devCenterName <devCenterName>"
        return 1
    }

    if (-not (Test-Path "./devBox/devCenter/createDevCenterProject.ps1")) {
        Write-Error "Error: createDevCenterProject.ps1 script not found!"
        return 1
    }

    Write-Output "Creating Dev Center project: $devCenterName"
    & ./devBox/devCenter/createDevCenterProject.ps1 -location $location -subscriptionId $subscriptionId -devBoxResourceGroupName $devBoxResourceGroupName -devCenterName $devCenterName

    Demo-Script
}

# Function to set up a Dev Box Definition
function Set-UpDevBoxDefinition {
    param (
        [string]$imageNameDevBox
    )

    Write-Output "Creating Dev Box Definition with image: $imageNameDevBox..."

    # Execute the script to create the Dev Box Definition
    if (& ./devBox/devCenter/createDevBoxDefinition.ps1 -subscriptionId $subscriptionId -location $location -devBoxResourceGroupName $devBoxResourceGroupName -devCenterName $devCenterName -imageGalleryName $imageGalleryName -imageNameDevBox $imageNameDevBox -networkConnectionName $networkConnectionName -buildImage $buildImage) {
        Write-Output "Dev Box Definition created successfully."
    } else {
        Write-Error "Error: Failed to create Dev Box Definition."
        exit 1
    }
}

# Function to set up an image template
function Set-UpImageTemplate {
    param (
        [string]$outputFilePath,
        [string]$subscriptionId,
        [string]$imageGalleryResourceGroupName,
        [string]$location,
        [string]$imageName,
        [string]$identityName,
        [string]$imageTemplateFile,
        [string]$imageGalleryName,
        [string]$offer,
        [string]$imgSku,
        [string]$publisher,
        [string]$identityResourceGroupName
    )

    if ([string]::IsNullOrEmpty($outputFilePath) -or [string]::IsNullOrEmpty($subscriptionId) -or [string]::IsNullOrEmpty($imageGalleryResourceGroupName) -or [string]::IsNullOrEmpty($location) -or [string]::IsNullOrEmpty($imageName) -or [string]::IsNullOrEmpty($identityName) -or [string]::IsNullOrEmpty($imageTemplateFile) -or [string]::IsNullOrEmpty($imageGalleryName) -or [string]::IsNullOrEmpty($offer) -or [string]::IsNullOrEmpty($imgSku) -or [string]::IsNullOrEmpty($publisher) -or [string]::IsNullOrEmpty($identityResourceGroupName)) {
        Write-Error "Error: Missing required parameters."
        Write-Output "Usage: Set-UpImageTemplate -outputFilePath <outputFilePath> -subscriptionId <subscriptionId> -imageGalleryResourceGroupName <imageGalleryResourceGroupName> -location <location> -imageName <imageName> -identityName <identityName> -imageTemplateFile <imageTemplateFile> -imageGalleryName <imageGalleryName> -offer <offer> -imgSku <imgSku> -publisher <publisher> -identityResourceGroupName <identityResourceGroupName>"
        return 1
    }

    Write-Output "Setting up image template..."
    if (-not (& ./devBox/computeGallery/createVMImageTemplate.ps1 -outputFilePath $outputFilePath -subscriptionId $subscriptionId -imageGalleryResourceGroupName $imageGalleryResourceGroupName -location $location -imageName $imageName -identityName $identityName -imageTemplateFile $imageTemplateFile -imageGalleryName $imageGalleryName -offer $offer -imgSku $imgSku -publisher $publisher -identityResourceGroupName $identityResourceGroupName)) {
        Write-Error "Error: Failed to set up image template."
        return 1
    }
}

# Function to build images
function Build-Images {
    param (
        [bool]$buildImage,
        [string]$subscriptionId,
        [string]$imageGalleryResourceGroupName,
        [string]$location,
        [string]$identityName,
        [string]$imageGalleryName,
        [string]$identityResourceGroupName,
        [string]$devBoxResourceGroupName,
        [string]$devCenterName,
        [string]$networkConnectionName,
        [string]$branch
    )

    $imageParams = @{}
    if ($buildImage) {
        Write-Output "Building images..."
        $imageParams["BackEnd-Docker-Img"] = "VS22-BackEnd-Docker petv2-Fabric ./DownloadedTempTemplates/BackEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/computeGallery/backEndEngineerImgTemplateDocker.json Contoso"
        $imageParams["FrontEnd-Docker-Img"] = "VS22-FrontEnd-Docker petv2-Fabric ./DownloadedTempTemplates/FrontEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/computeGallery/frontEndEngineerImgTemplateDocker.json Contoso"
        foreach ($imageName in $imageParams.Keys) {
            $params = $imageParams[$imageName] -split ' '
            Set-UpImageTemplate -outputFilePath $params[2] -subscriptionId $subscriptionId -imageGalleryResourceGroupName $imageGalleryResourceGroupName -location $location -imageName $imageName -identityName $identityName -imageTemplateFile $params[3] -imageGalleryName $imageGalleryName -offer $params[1] -imgSku $params[0] -publisher $params[4]
            Set-UpDevBoxDefinition -imageNameDevBox $imageName
        }
    } else {
        Write-Output "Skipping image build..."
        $imageParams["BackEndEngineer-vm"] = "microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2"
        $imageParams["FrontEndEngineer-vm"] = "microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365"
        foreach ($imageName in $imageParams.Keys) {
            $imageNameDevBox = $imageParams[$imageName]
            # Create Dev Box Definition
            Write-Output "Creating Dev Box Definition..."
            Set-UpDevBoxDefinition -imageNameDevBox $imageNameDevBox
        }
    }
}

# Function to create a Dev Center project
function Create-DevCenterProject {
    param (
        [string]$location,
        [string]$subscriptionId,
        [string]$devBoxResourceGroupName,
        [string]$devCenterName
    )

    if ([string]::IsNullOrEmpty($location) -or [string]::IsNullOrEmpty($subscriptionId) -or [string]::IsNullOrEmpty($devBoxResourceGroupName) -or [string]::IsNullOrEmpty($devCenterName)) {
        Write-Error "Error: Missing required parameters."
        Write-Output "Usage: Create-DevCenterProject -location <location> -subscriptionId <subscriptionId> -devBoxResourceGroupName <devBoxResourceGroupName> -devCenterName <devCenterName>"
        return 1
    }

    if (-not (Test-Path "./devBox/devCenter/createDevCenterProject.ps1")) {
        Write-Error "Error: createDevCenterProject.ps1 script not found!"
        return 1
    }

    Write-Output "Creating Dev Center project: $devCenterName"
    & ./devBox/devCenter/createDevCenterProject.ps1 -location $location -subscriptionId $subscriptionId -devBoxResourceGroupName $devBoxResourceGroupName -devCenterName $devCenterName

    Demo-Script
}

# Function to set up a Dev Box Definition
function Set-UpDevBoxDefinition {
    param (
        [string]$imageNameDevBox
    )

    Write-Output "Creating Dev Box Definition with image: $imageNameDevBox..."

    # Execute the script to create the Dev Box Definition
    if (& ./devBox/devCenter/createDevBoxDefinition.ps1 -subscriptionId $subscriptionId -location $location -devBoxResourceGroupName $devBoxResourceGroupName -devCenterName $devCenterName -imageGalleryName $imageGalleryName -imageNameDevBox $imageNameDevBox -networkConnectionName $networkConnectionName -buildImage $buildImage) {
        Write-Output "Dev Box Definition created successfully."
    } else {
        Write-Error "Error: Failed to create Dev Box Definition."
        exit 1
    }
}

# Function to set up an image template
function Set-UpImageTemplate {
    param (
        [string]$outputFilePath,
        [string]$subscriptionId,
        [string]$imageGalleryResourceGroupName,
        [string]$location,
        [string]$imageName,
        [string]$identityName,
        [string]$imageTemplateFile,
        [string]$imageGalleryName,
        [string]$offer,
        [string]$imgSku,
        [string]$publisher,
        [string]$identityResourceGroupName
    )

    if ([string]::IsNullOrEmpty($outputFilePath) -or [string]::IsNullOrEmpty($subscriptionId) -or [string]::IsNullOrEmpty($imageGalleryResourceGroupName) -or [string]::IsNullOrEmpty($location) -or [string]::IsNullOrEmpty($imageName) -or [string]::IsNullOrEmpty($identityName) -or [string]::IsNullOrEmpty($imageTemplateFile) -or [string]::IsNullOrEmpty($imageGalleryName) -or [string]::IsNullOrEmpty($offer) -or [string]::IsNullOrEmpty($imgSku) -or [string]::IsNullOrEmpty($publisher) -or [string]::IsNullOrEmpty($identityResourceGroupName)) {
        Write-Error "Error: Missing required parameters."
        Write-Output "Usage: Set-UpImageTemplate -outputFilePath <outputFilePath> -subscriptionId <subscriptionId> -imageGalleryResourceGroupName <imageGalleryResourceGroupName> -location <location> -imageName <imageName> -identityName <identityName> -imageTemplateFile <imageTemplateFile> -imageGalleryName <imageGalleryName> -offer <offer> -imgSku <imgSku> -publisher <publisher> -identityResourceGroupName <identityResourceGroupName>"
        return 1
    }

    Write-Output "Setting up image template..."
    if (-not (& ./devBox/computeGallery/createVMImageTemplate.ps1 -outputFilePath $outputFilePath -subscriptionId $subscriptionId -imageGalleryResourceGroupName $imageGalleryResourceGroupName -location $location -imageName $imageName -identityName $identityName -imageTemplateFile $imageTemplateFile -imageGalleryName $imageGalleryName -offer $offer -imgSku $imgSku -publisher $publisher -identityResourceGroupName $identityResourceGroupName)) {
        Write-Error "Error: Failed to set up image template."
        return 1
    }
}

# Function to build images
function Build-Images {
    param (
        [bool]$buildImage,
        [string]$subscriptionId,
        [string]$imageGalleryResourceGroupName,
        [string]$location,
        [string]$identityName,
        [string]$imageGalleryName,
        [string]$identityResourceGroupName,
        [string]$devBoxResourceGroupName,
        [string]$devCenterName,
        [string]$networkConnectionName,
        [string]$branch
    )

    $imageParams = @{}
    if ($buildImage) {
        Write-Output "Building images..."
        $imageParams["BackEnd-Docker-Img"] = "VS22-BackEnd-Docker petv2-Fabric ./DownloadedTempTemplates/BackEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/computeGallery/backEndEngineerImgTemplateDocker.json Contoso"
        $imageParams["FrontEnd-Docker-Img"] = "VS22-FrontEnd-Docker petv2-Fabric ./DownloadedTempTemplates/FrontEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/computeGallery/frontEndEngineerImgTemplateDocker.json Contoso"
        foreach ($imageName in $imageParams.Keys) {
            $params = $imageParams[$imageName] -split ' '
            Set-UpImageTemplate -outputFilePath $params[2] -subscriptionId $subscriptionId -imageGalleryResourceGroupName $imageGalleryResourceGroupName -location $location -imageName $imageName -identityName $identityName -imageTemplateFile $params[3] -imageGalleryName $imageGalleryName -offer $params[1] -imgSku $params[0] -publisher $params[4]
            Set-UpDevBoxDefinition -imageNameDevBox $imageName
        }
    } else {
        Write-Output "Skipping image build..."
        $imageParams["BackEndEngineer-vm"] = "microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2"
        $imageParams["FrontEndEngineer-vm"] = "microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365"
        foreach ($imageName in $imageParams.Keys) {
            $imageNameDevBox = $imageParams[$imageName]
            # Create Dev Box Definition
            Write-Output "Creating Dev Box Definition..."
            Set-UpDevBoxDefinition -imageNameDevBox $imageNameDevBox
        }
    }
}

# Function to prompt the user for continuation if scriptDemo is true
function Demo-Script {
    param (
        [bool]$scriptDemo
    )

    if ($scriptDemo) {
        $answer = Read-Host "Do you want to continue? (y/n)"
        if ($answer -eq "y") {
            Clear-Host
            Write-Output "Continuing..."
        } else {
            Write-Output "Stopping the script."
            exit 1
        }
    }
}

# Main function to deploy Microsoft DevBox
function Deploy-MicrosoftDevBox {
    param (
        [bool]$scriptDemo
    )

    Clear-Host

    Write-Output "Starting Deployment..."
    Azure-Login -subscriptionName $subscriptionName

    $subscriptionId = az account show --query id --output tsv

    Write-Output "The Subscription ID is: $subscriptionId"

    Deploy-ResourcesOrganization

    Create-Identity -subscriptionId $subscriptionId

    Deploy-Network

    Deploy-ComputeGallery

    Deploy-DevCenter

    Build-Images

    Write-Output "Deployment Completed Successfully!"
}

# Start the deployment process
Deploy-MicrosoftDevBox -scriptDemo $scriptDemo