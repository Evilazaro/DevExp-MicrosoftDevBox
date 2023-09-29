# Define the usage of the script to inform users about expected parameters
function Usage {
    Write-Output "Usage: $PSCommandPath <location> <devBoxDefinitionName> <networkConnectionName> <poolName> <projectName> <devBoxResourceGroupName>"
}

# Validate the number of arguments passed to the script
if ($args.Count -ne 6) {
    Write-Output "Error: Incorrect number of arguments"
    Usage
    exit 1
}

# Assign arguments to variables with meaningful names in PascalCase
$Location = $args[0]
$DevBoxDefinitionName = $args[1]
$NetworkConnectionName = $args[2]
$PoolName = $args[3]
$ProjectName = $args[4]
$DevBoxResourceGroupName = $args[5]

# Function to create a DevCenter admin pool
function CreateDevCenterAdminPool {
    Write-Output "Creating DevCenter admin pool with the following parameters:"
    Write-Output "Location: $Location"
    Write-Output "DevBox Definition Name: $DevBoxDefinitionName"
    Write-Output "Network Connection Name: $NetworkConnectionName"
    Write-Output "Pool Name: $PoolName"
    Write-Output "Project Name: $ProjectName"
    Write-Output "Resource Group: $DevBoxResourceGroupName"
    
    az devcenter admin pool create `
        --location $Location `
        --devbox-definition-name $DevBoxDefinitionName `
        --network-connection-name $NetworkConnectionName `
        --pool-name $PoolName `
        --project-name $ProjectName `
        --resource-group $DevBoxResourceGroupName `
        --local-administrator "Enabled" `
        --tags "Division=Contoso-Platform" `
               "Environment=Prod" `
               "Offer=Contoso-DevWorkstation-Service" `
               "Team=Engineering" `
               "Solution=eShop"
               
    # Check the exit status of the last command and echo a message accordingly
    if ($LASTEXITCODE -eq 0) {
        Write-Output "DevCenter admin pool created successfully."
    } else {
        Write-Output "Failed to create DevCenter admin pool. Please check the parameters and try again."
        exit 1
    }
}

# Call the function to create a DevCenter admin pool
CreateDevCenterAdminPool
