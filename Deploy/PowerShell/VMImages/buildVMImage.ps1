# Stop on any error
$ErrorActionPreference = "Stop"

Write-Host "Checking necessary tools..."

# Check if necessary tools are available
$tools = @("wget", "az", "sed")
foreach ($tool in $tools) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "$tool is required but not installed. Exiting."
        exit 1
    }
}

# Assign command line arguments to variables
$outputFile = $args[0]
$subscriptionID = $args[1]
$galleryResourceGroup = $args[2]
$location = $args[3]
$imageName = $args[4]
$identityName = $args[5]
$imageTemplateFile = $args[6]
$galleryName = $args[7]
$offer = $args[8]
$sku = $args[9]
$publisher = $args[10]

Write-Host "Starting the process to create Image Definitions..."
$imageDefName = "${imageName}-def"

# Create Image Definition
Write-Host "Creating image definition..."
az sig image-definition create `
    --resource-group $galleryResourceGroup `
    --gallery-name $galleryName `
    --gallery-image-definition $imageDefName `
    --os-type Windows `
    --publisher $publisher `
    --offer $offer `
    --sku $sku `
    --os-state generalized `
    --hyper-v-generation V2 `
    --features "SecurityType=TrustedLaunch" `
    --location $location

# Download image template
Write-Host "Downloading image template from $imageTemplateFile..."
Invoke-WebRequest -Headers @{"Cache-Control"="no-cache"; "Pragma"="no-cache"} -Uri $imageTemplateFile -OutFile $outputFile
Write-Host "Successfully downloaded the image template to $outputFile."

# Replace placeholders in the downloaded template
Write-Host "Updating placeholders in the template..."
(Get-Content -Path $outputFile).Replace('<subscriptionID>', $subscriptionID).Replace('<rgName>', $galleryResourceGroup).Replace('<imageName>', $imageName).Replace('<imageDefName>', $imageDefName).Replace('<sharedImageGalName>', $galleryName).Replace('<location>', $location).Replace('<identityName>', $identityName) | Set-Content -Path $outputFile
Write-Host "Template placeholders updated."

# Deploy resources in Azure
Write-Host "Creating image resource '$imageName' in Azure..."
az deployment group create `
    --resource-group $galleryResourceGroup `
    --template-file $outputFile 

Write-Host "Successfully created image resource '$imageName' in Azure."

# Initiate the build process for the image
Write-Host "Starting the build process for Image '$imageName' in Azure..."
$resourceId = az resource show --name $imageName --resource-group $galleryResourceGroup --resource-type "Microsoft.VirtualMachineImages/imageTemplates" --query id --output tsv
az resource invoke-action `
    --ids $resourceId `
    --action "Run" `
    --request-body '{}' `
    --query properties.outputs

# Create image version
az sig image-version create `
    --resource-group $galleryResourceGroup `
    --gallery-name $galleryName `
    --gallery-image-definition $imageDefName `
    --gallery-image-version 1.0.0 `
    --target-regions $location `
    --managed-image "/subscriptions/$subscriptionID/resourceGroups/$galleryResourceGroup/providers/Microsoft.Compute/images/$imageName" `
    --replica-count 1 `
    --location $location

Write-Host "Build process for Image '$imageName' has been initiated successfully!"
