# Define Variables
$branch = "Dev"

# Ensure all required parameters are provided
if ($args.Count -ne 5) {
    Write-Host "Usage: $($MyInvocation.InvocationName) <location> <networkResourceGroupName> <vnetName> <subNetName> <networkConnectionName>"
    exit 1
}

# Assign positional parameters to meaningful variable names
$location = $args[0]
$networkResourceGroupName = $args[1]
$vnetName = $args[2]
$subNetName = $args[3]
$networkConnectionName = $args[4]

# Define the template file path
$templateUrl = "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/Deploy/ARMTemplates/network/networkConnectionTemplate.json"

# Echo starting the operation
Write-Host "Initiating the deployment in the resource group: $networkResourceGroupName, location: $location."

# Retrieve the subnet ID
Write-Host "Retrieving Subnet ID for $subNetName..."
$subnetId = az network vnet subnet show `
    --resource-group $networkResourceGroupName `
    --vnet-name $vnetName `
    --name $subNetName `
    --query id `
    --output tsv

# Check the successful retrieval of subnetId
if (-not $subnetId) {
    Write-Host "Error: Unable to retrieve the Subnet ID for $subNetName in $vnetName."
    exit 1
}
Write-Host "Subnet ID for $subNetName retrieved successfully."

# Deploy the ARM template
Write-Host "Deploying ARM Template from $templateUrl..."
az deployment group create `
    --resource-group $networkResourceGroupName `
    --template-uri $templateUrl `
    --parameters `
        name=$networkConnectionName `
        vnetId=$subnetId `
        location=$location 

# Check the status of the last command
if ($LASTEXITCODE -eq 0) {
    Write-Host "ARM Template deployment initiated successfully."
} else {
    Write-Host "Error: ARM Template deployment failed."
    exit 1
}

# Exit normally
exit 0
