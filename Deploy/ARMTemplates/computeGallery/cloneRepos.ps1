# Set the execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Define repositories to clone
$repositories = @(
    @{
        Url = 'https://github.com/Evilazaro/eShop.git'
        Destination = 'c:\eShop'
        Description = 'eShopOnContainers Repository'
    },
    @{
        Url = 'https://github.com/Evilazaro/eShopAPIM.git'
        Destination = 'c:\eShopAPIM'
        Description = 'eShopOnContainers APIs Repository'
    },
    @{
        Url = 'https://github.com/Evilazaro/TailwindTraders-Website.git'
        Destination = 'c:\TailwindTraders-Website'
        Description = 'TailwindTraders-Website Repository'
    },
    @{
        Url = 'https://github.com/Evilazaro/TailwindTraders-Backend.git'
        Destination = 'c:\TailwindTraders-Backend'
        Description = 'TailwindTraders-Backend Repository'
    },
    @{
        Url = 'https://github.com/mspnp/aks-fabrikam-dronedelivery.git'
        Destination = 'c:\aks-fabrikam-dronedelivery'
        Description = 'Azure Kubernetes Service (AKS) Fabrikam Drone Delivery'
    }

)

function Clone-Repositories {
    param (
        [Parameter(Mandatory = $true)]
        [Array]$Repositories
    )

    foreach ($repo in $Repositories) {
        Write-Output "Cloning $($repo.Description)"
        try {
            git clone $repo.Url $repo.Destination
        } catch {
            throw "Failed to clone $($repo.Description) from $($repo.Url) to $($repo.Destination)"
        }
    }
}

Clone-Repositories -Repositories $repositories