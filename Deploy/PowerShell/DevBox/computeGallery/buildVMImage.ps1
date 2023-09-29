# Ensure that the necessary number of arguments are provided
if ($args.Length -ne 11) {
    Write-Host "Usage: $ScriptName outputFile subscriptionID resourceGroupName location imageName identityName imageTemplateFile galleryName offer imgSKU publisher"
    exit 1
}

# Assign command-line arguments to variables
$outputFile = $args[0]
$subscriptionID = $args[1]
$resourceGroupName = $args[2]
$location = $args[3]
$imageName = $args[4]
$identityName = $args[5]
$imageTemplateFile = $args[6]
$galleryName = $args[7]
$offer = $args[8]
$imgSKU = $args[9]
$publisher = $args[10]

# Starting the process to create image definitions
Write-Host "Initiating the process to create image definitions..."

# Construct image definition name and feature list
$imageDefName = "${imageName}-def"
$features = "SecurityType=TrustedLaunch IsHibernateSupported=true"

# Creating image definition using az cli
Write-Host "Creating image definition..."
az sig image-definition create `
    --resource-group $resourceGroupName `
    --gallery-name $galleryName `
    --gallery-image-definition $imageDefName `
    --os-type Windows `
    --publisher $publisher `
    --offer $offer `
    --sku $imgSKU `
    --os-state generalized `
    --hyper-v-generation V2 `
    --features "$features" `
    --location $location `
    --tags "division=Contoso-Platform" `
           "Environment=Prod" `
           "offer=Contoso-DevWorkstation-Service" `
           "Team=Engineering" `
           "division=Contoso-Platform" `
           "solution=eShop" `
           "businessUnit=e-Commerce"

# Download the image template file
Write-Host "Downloading image template from $imageTemplateFile..."
Invoke-WebRequest -Uri $imageTemplateFile -OutFile $outputFile
Write-Host "Image template successfully downloaded to $outputFile."

# Replacing placeholders in the downloaded template with actual values
Write-Host "Updating placeholders in the template..."
(Get-Content $outputFile) | ForEach-Object {$_ -replace '<subscriptionID>', $subscriptionID} | Set-Content $outputFile
(Get-Content $outputFile) | ForEach-Object {$_ -replace '<rgName>', $resourceGroupName} | Set-Content $outputFile
(Get-Content $outputFile) | ForEach-Object {$_ -replace '<imageName>', $imageName} | Set-Content $outputFile
(Get-Content $outputFile) | ForEach-Object {$_ -replace '<imageDefName>', $imageDefName} | Set-Content $outputFile
(Get-Content $outputFile) | ForEach-Object {$_ -replace '<sharedImageGalName>', $galleryName} | Set-Content $outputFile
(Get-Content $outputFile) | ForEach-Object {$_ -replace '<location>', $location} | Set-Content $outputFile
(Get-Content $outputFile) | ForEach-Object {$_ -replace '<identityName>', $identityName} | Set-Content $outputFile
Write-Host "Template placeholders successfully updated."

# Deploy resources in Azure using the updated template
Write-Host "Creating image resource '$imageName' in Azure..."
az deployment group create `
    --resource-group $resourceGroupName `
    --template-file $outputFile

Write-Host "Image resource '$imageName' successfully created in Azure."

# Initiate the build process for the image in Azure
Write-Host "Initiating the build process for image '$imageName' in Azure..."
az resource invoke-action `
    --ids (az resource show --name $imageName --resource-group $resourceGroupName --resource-type "Microsoft.VirtualMachineImages/imageTemplates" --query id --output tsv) `
    --action "Run" `
    --request-body '{}' `
    --query properties.outputs

Write-Host "Build process for image '$imageName' successfully initiated in Azure."
