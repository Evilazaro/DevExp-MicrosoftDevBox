# Ensure a command line argument is provided
if ($args.Length -ne 1) {
    Write-Host "Usage: $0 <subscriptionId>"
    exit 1
}

# Assigning argument to a variable for better readability
$subscriptionName = $args[0]

# Step 1: Logging in to Azure
Write-Host "Attempting to log in to Azure..."
Connect-AzureRmAccount
$subscriptionId = (Get-AzureRmSubscription -SubscriptionName $subscriptionName).Id
Write-Host "Successfully logged in to Azure."

# Step 2: Setting the Azure subscription
Write-Host "Attempting to set subscription to $subscriptionId..."
try {
    # Check if the subscription exists and is valid
    az account set --subscription $subscriptionName
    Set-AzureRmContext -Context (Get-AzureRmSubscription -SubscriptionId $subscriptionId) -ErrorAction Stop
    Write-Host "Successfully set Azure subscription to $subscriptionId."
} catch {
    Write-Host "Failed to set Azure subscription to $subscriptionId. Please check if the subscription ID is valid and you have access to it."
    exit 1
}

# Additional comments for future steps or improvements can be added below this line.

