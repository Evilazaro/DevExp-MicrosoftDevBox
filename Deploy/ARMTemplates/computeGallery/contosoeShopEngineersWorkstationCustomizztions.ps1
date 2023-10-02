<#
.SYNOPSIS
This script clones repositories, installs Docker Desktop, and VS Code Extensions.

.DESCRIPTION
The script performs the following actions:
- Sets the execution policy to Bypass for the process scope.
- Clones the specified repositories to the specified destinations.
- Installs Docker Desktop using Chocolatey.
- Installs specified VS Code Extensions.
#>

# Set the execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Define repositories to clone
$repositories = @(
    @{
        Url = 'https://github.com/Evilazaro/eShopOnContainers.git'
        Destination = 'c:\eShop'
        Description = 'eShopOnContainers Repository'
    },
    @{
        Url = 'https://github.com/Evilazaro/eShopAPIM.git'
        Destination = 'c:\eShopAPIM'
        Description = 'eShopOnContainers APIs Repository'
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

function Install-Chocolatey{
    Write-Output "Installing Chocolatey"
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
    } catch {
        throw "Failed to install Chocolatey"
    }
}

function Install-DockerDesktop {
    Write-Output "Installing Docker Desktop"
    try {
        choco install -y --ignore-checksums docker-desktop --ia '--quiet --accept-license'
    } catch {
        throw "Failed to install Docker Desktop"
    }
}

function Install-VSCodeExtensions {
    Write-Output "Installing VS Code Extensions"
    try {
        code --install-extension ms-vscode.vscode-node-azure-pack --force
    } catch {
        throw "Failed to install VS Code Extensions"
    }
}

# Execute Functions
try {
    Clone-Repositories -Repositories $repositories
    Install-Chocolatey
    Install-DockerDesktop
    Write-Output "Script completed successfully"
} catch {
    Write-Error $_.Exception.Message
    throw $_.Exception
}
