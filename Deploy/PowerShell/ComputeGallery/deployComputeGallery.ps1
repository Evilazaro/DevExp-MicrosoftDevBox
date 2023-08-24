# Exit on any error to ensure the script stops if there's a problem
$ErrorActionPreference = "Stop"

# Check if the correct number of arguments are provided
if ($args.Count -ne 3) {
    Write-Host "Usage: $PSCommandPath <galleryName> <location> <galleryResourceGroup>"
    exit 1
}

# Assign input arguments to descriptive variable names
$galleryName = $args[0]
$location = $args[1]
$galleryResourceGroup = $args[2]

# Define the template file URL and the output file name for clarity
$galleryTemplateURL = "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Compute-Gallery-Template.json"
$outputFilePath = "./DownloadedTempTemplates/Compute-Gallery-Template-Output.json"

# Notify the user that the template is being downloaded
Write-Host "Downloading template file from: $galleryTemplateURL"

# Download the template file
Invoke-WebRequest -Headers @{"Cache-Control"="no-cache"; "Pragma"="no-cache"} -Uri $galleryTemplateURL -OutFile $outputFilePath -ErrorAction Stop | Out-Null

# Check if the template file download failed
if (-not $? -or -not (Test-Path $outputFilePath)) {
    Write-Host "Error downloading the template file!"
    exit 1
}

# Replace placeholders with provided values in the downloaded template
(Get-Content -Path $outputFilePath) | 
    Foreach-Object { $_ -replace "<galleryName>", $galleryName } | 
    Foreach-Object { $_ -replace "<location>", $location } | 
    Set-Content -Path $outputFilePath

# Notify the user that the resource is about to be created in Azure
Write-Host "Creating resource in Azure with the provided details..."

# Create resource in Azure
az deployment group create `
    --name "$galleryName" `
    --template-file "$outputFilePath" `
    --resource-group "$galleryResourceGroup" | Out-Null

# Check if the resource creation in Azure failed
if (-not $?) {
    Write-Host "Error creating the resource in Azure!"
    exit 1
}

# Notify the user that the entire operation has been completed
Write-Host "Operation completed successfully!"
