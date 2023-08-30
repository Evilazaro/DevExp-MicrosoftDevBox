# Script for deploying an Azure Resource Manager (ARM) template.

# --- Variables ---
$TEMPLATE_URL = 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Network-Connection-Template.json'
$OUTPUT_FILE_PATH = '.\DownloadedTempTemplates\Network-Connection-Template-Output.json'

# --- Functions ---
# Print usage information
function Print-Usage {
    Write-Output "Usage: $PSCommandPath <location> <subscriptionId> <resourceGroupName> <vnetName> <subNetName>"
}

# --- Main ---

# Ensure the correct number of arguments is provided.
if ($args.Count -ne 5) {
    Write-Output "Error: Incorrect number of arguments provided."
    Print-Usage
    exit 1
}

# Assign command-line arguments to descriptive variables.
$LOCATION = $args[0]
$SUBSCRIPTION_ID = $args[1]
$RESOURCE_GROUP_NAME = $args[2]
$VNET_NAME = $args[3]
$SUBNET_NAME = $args[4]

# Download the ARM template from the URL to the specified path.
Write-Output "Downloading the ARM template..."
Invoke-WebRequest -Headers @{"Cache-Control" = "no-cache"; "Pragma" = "no-cache"} -Uri $TEMPLATE_URL -OutFile $OUTPUT_FILE_PATH

# Check if the download was successful
if ($LASTEXITCODE -ne 0) {
    Write-Output "Error downloading the ARM template. Exiting."
    exit 2
}

# Replace placeholders in the template file with provided arguments.
Write-Output "Updating the ARM template with provided values..."
(Get-Content $OUTPUT_FILE_PATH) |
    ForEach-Object {
        $_ -replace '<location>', $LOCATION `
           -replace '<subscriptionId>', $SUBSCRIPTION_ID `
           -replace '<resourceGroupName>', $RESOURCE_GROUP_NAME `
           -replace '<vnetName>', $VNET_NAME `
           -replace '<subNetName>', $SUBNET_NAME
    } | Set-Content $OUTPUT_FILE_PATH

# Start the deployment using the Azure CLI.
Write-Output "Initiating deployment using the ARM Template..."
if (az deployment group create `
    --name Network-Connection-Template `
    --template-file $OUTPUT_FILE_PATH `
    --resource-group $RESOURCE_GROUP_NAME) {
    Write-Output "Deployment was successful!"
}
else {
    Write-Output "Deployment failed. Please check the provided parameters and try again."
    exit 3
}
