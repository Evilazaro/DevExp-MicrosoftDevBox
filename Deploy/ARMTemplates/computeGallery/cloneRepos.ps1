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
            git config --global --add safe.directory $repo.destination
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
            url = 'https://github.com/Evilazaro/eShopOnContainers.git'
            destination = 'c:\projects\eShop'
            description = 'eShop running on containers'
        },
        @{
            url = 'https://github.com/Evilazaro/eShopAPI.git'
            destination = 'c:\projects\eShopAPI'
            description = 'eShop API'
        },
        @{
            url = 'https://github.com/dotnet-architecture/eShopOnBlazor.git'
            destination = 'c:\projects\eShopOnBlazor'
            description = 'eShop on Blazor WebAssembly'
        }
    )

    cloneRepositories -reposToClone $repositories
}

# Call the main function to run the script
main
