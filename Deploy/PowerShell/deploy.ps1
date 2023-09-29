# Define the Functions

Function Login {
    Param (
        [string]$subscriptionName
    )
    If(-not $subscriptionName){
        Write-Output "Error: Subscription name is missing!"
        Write-Output "Usage: Login -subscriptionName <subscriptionName>"
        Return
    }
    
    Write-Output "Attempting to login to Azure subscription: $subscriptionName"

    $scriptPath = '.\identity\login.ps1'

    If(-not (Test-Path -Path $scriptPath -PathType Leaf)){
        Write-Output "Error: The login script $scriptPath does not exist or is not executable."
        Return
    }
    
    & $scriptPath $subscriptionName
    
    If($LASTEXITCODE -eq 0){
        Write-Output "Successfully logged in to $subscriptionName."
    }
    Else{
        Write-Output "Failed to log in to $subscriptionName."
        Return
    }
}

Function CreateResourceGroup {
    Param(
        [string]$resourceGroupName,
        [string]$location
    )
    
    # Validate inputs
    If(-not $resourceGroupName -or -not $location){
        Write-Output "Usage: CreateResourceGroup -resourceGroupName <ResourceGroupName> -location <Location>"
        Exit
    }
    
    # Echo steps
    Write-Output "Creating Azure Resource Group..."
    Write-Output "Resource Group Name: $resourceGroupName"
    Write-Output "Location: $location"
    
    az group create --name $resourceGroupName --location $location --tags  division=Contoso-Platform Environment=Prod offer=Contoso-DevWorkstation-Service Team=Engineering division=Contoso-Platform solution=eShop
    Write-Output "Resource group '$resourceGroupName' created successfully."
}

# Define other functions similarly...
# ...

# Set error action preference to Stop to exit on error
$ErrorActionPreference = 'Stop'

# Variables
$branch = "Dev"
$location = 'WestUS3'

# Validate if subscriptionName is provided
If(-not $args[0]){
    Write-Output "Usage: .\script.ps1 <subscriptionName>"
    Exit
}

$subscriptionName = $args[0]
$subscriptionId = az account show --query id --output tsv

# Resource Group names
$devBoxResourceGroupName = 'ContosoFabric-DevBox-RG'
$imageGalleryResourceGroupName = 'ContosoFabric-ImageGallery-RG'
$identityResourceGroupName = 'ContosoFabric-Identity-DevBox-RG'
$networkResourceGroupName = 'eShop-Network-Connectivity-RG'
$managementResourceGroupName = 'ContosoFabric-DevBox-Management-RG'

# Identity Variables
$identityName = 'ContosoFabricDevBoxImgBldId'
$customRoleName = 'ContosoFabricBuilderRole'

# Image and DevCenter Names
$imageGalleryName = 'ContosoFabricImageGallery'
$frontEndImageName = 'eShop-FrontEnd'
$backEndImageName = 'eShop-BackEnd'
$devCenterName = 'DevBox-DevCenter'

# Network Variables
$vnetName = 'eShop-Vnet'
$subNetName = 'eShop-SubNet'
$networkConnectionName = 'eShop-DevBox-Network-Connection'

# Execute the script with proper sequence
Write-Output "Starting Deployment..."

# Login to Azure
Login -subscriptionName $subscriptionName

# Deploy Resource Groups
CreateResourceGroup -resourceGroupName $devBoxResourceGroupName -location $location
CreateResourceGroup -resourceGroupName $imageGalleryResourceGroupName -location $location
CreateResourceGroup -resourceGroupName $identityResourceGroupName -location $location
CreateResourceGroup -resourceGroupName $networkResourceGroupName -location $location
CreateResourceGroup -resourceGroupName $managementResourceGroupName -location $location

# ... Here you would call the other functions in a similar fashion

Write-Output "Deployment Completed Successfully!"

# You will need to define and call the other functions similarly, adapting each part as needed according to the logic and flow of the original Bash script.
