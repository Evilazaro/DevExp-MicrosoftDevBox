# This script creates an image definition in a shared image gallery, retrieves the IDs of image gallery and user-assigned identity,
# creates a deployment group and invokes an action on a resource.

# Ensure the script exits when a command fails
$ErrorActionPreference = "Stop"

# Usage instructions for the script if not all parameters are provided
if ($args.Length -lt 12) {
    Write-Host "Usage: <ScriptName>.ps1 <outputFile> <subscriptionID> <resourceGroupName> <location> <imageName> <identityName> <imageFileUri> <galleryName> <offer> <imgSKU> <publisher> <identityResourceGroupName>"
    exit 1
}

# Assign command-line arguments to variables with descriptive names
$outputFile = $args[0]
$subscriptionID = $args[1]
$resourceGroupName = $args[2]
$location = $args[3]
$imageName = $args[4]
$identityName = $args[5]
$imageFileUri = $args[6]
$galleryName = $args[7]
$offer = $args[8]
$imgSKU = $args[9]
$publisher = $args[10]
$identityResourceGroupName = $args[11]

# Construct image definition name
$imageDefName = "${imageName}Def"

# Define image features
$features = "SecurityType=TrustedLaunch IsHibernateSupported=true"

# Log the step being executed
Write-Host "Creating image definition..."

# Create image definition in a shared image gallery
az sig image-definition create `
    --resource-group "$resourceGroupName" `
    --gallery-name "$galleryName" `
    --gallery-image-definition "$imageDefName" `
    --os-type Windows `
    --publisher "$publisher" `
    --offer "$offer" `
    --sku "$imgSKU" `
    --os-state generalized `
    --hyper-v-generation V2 `
    --features "$features" `
    --location "$location" `
    --tags  "division=Contoso-Platform" "Environment=Prod" "offer=Contoso-DevWorkstation-Service" "Team=Engineering" "solution=eShop" "businessUnit=e-Commerce"

# Log the step being executed
Write-Host "Retrieving the ID of the image gallery..."

# Retrieve the ID of the image gallery
$imageGalleryId = az sig show --resource-group "$resourceGroupName" `
                --gallery-name "$galleryName" --query id --output tsv

# Log the step being executed
Write-Host "Retrieving the ID of the user-assigned identity..."

# Retrieve the ID of the user-assigned identity
$userAssignedId = az identity show --resource-group "$identityResourceGroupName" `
                --name "$identityName" --query id --output tsv

# Log the step being executed
Write-Host "Creating a deployment group..."

# Create a deployment group
az deployment group create `
    --resource-group "$resourceGroupName" `
    --template-uri "$imageFileUri"  `
    --parameters imgName="$imageName" `
                 imageGalleryId="$imageGalleryId" `
                 userAssignedId="$userAssignedId" `
                 location="$location"

# Log the step being executed
Write-Host "Invoking an action on the resource..."

# Invoke an action on the resource
az resource invoke-action `
    --ids $(az resource show --name "$imageName" --resource-group "$resourceGroupName" --resource-type "Microsoft.VirtualMachineImages/imageTemplates" --query id --output tsv) `
    --action "Run" `
    --request-body '{}' `
    --query properties.outputs

# Log the successful execution of the script
Write-Host "Script executed successfully."
