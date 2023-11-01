# Checks and sets the execution policy if needed
function initializeEnvironment {
    # Get current execution policy
    $currentPolicy = Get-ExecutionPolicy -Scope Process

    # Set execution policy if it's more restrictive than 'Bypass'
    if ($currentPolicy -ne 'Bypass') {
        Set-ExecutionPolicy Bypass -Scope Process -Force
    }
}

# Clones repositories based on given array of repository info
function cloneRepositories {
    param (
        [Parameter(Mandatory = $true)]
        [Array]$reposToClone
    )

    mkdir c:\projects
    icacls c:\projects /grant "Everyone:(OI)(CI)F" /T
    git config --global --add safe.directory C:/projects/

    foreach ($repo in $reposToClone) {
        Write-Output "Cloning $($repo.description)"

        try {
            git clone $repo.url $repo.destination
        } catch {
            throw "Failed to clone $($repo.description) from $($repo.url) to $($repo.destination)"
        }
    }
}

# Main script execution
function main {
    initializeEnvironment

    # Define repositories to clone
    $repositories = @(
        @{
            url = 'https://github.com/Evilazaro/eShop.git'
            destination = 'c:\projects\eShop'
            description = 'eShopOnContainers Repository'
        },
        @{
            url = 'https://github.com/Evilazaro/eShopAPIM.git'
            destination = 'c:\projects\eShopAPIM'
            description = 'eShopOnContainers APIs Repository'
        },
        @{
            url = 'https://github.com/Evilazaro/TailwindTraders-Website.git'
            destination = 'c:\projects\TailwindTraders-Website'
            description = 'TailwindTraders-Website Repository'
        },
        @{
            url = 'https://github.com/Evilazaro/TailwindTraders-Backend.git'
            destination = 'c:\projects\TailwindTraders-Backend'
            description = 'TailwindTraders-Backend Repository'
        },
        @{
            url = 'https://github.com/mspnp/aks-fabrikam-dronedelivery.git'
            destination = 'c:\projects\aks-fabrikam-dronedelivery'
            description = 'Azure Kubernetes Service (AKS) Fabrikam Drone Delivery'
        }
    )

    cloneRepositories -reposToClone $repositories
}

# Call the main function to run the script
main
