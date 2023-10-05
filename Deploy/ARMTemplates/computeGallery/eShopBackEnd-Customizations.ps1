
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

function Install-DockerDesktop {
    Write-Output "Installing Docker Desktop"
    try {
        $dockerTempFilePath="c:\DockerTemp"
        mkdir $dockerTempFilePath

        $packageArgs = @{
            packageName    = 'docker-desktop'
            softwareName   = 'Docker Desktop'
            url            = 'https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe' 
            fileFullPath   = "$($dockerTempFilePath)\dockerinstall.exe" 
            validExitCodes = @(0)
        }

        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($($packageArgs.url), $($packageArgs.fileFullPath))
        c:\DockerTemp\dockerinstall.exe install --wait --quiet --quiet --accept-license
    } catch {
        throw "Failed to install Docker Desktop"
    }
    Write-Output "Docker Desktop installed successfully"
}

function Install-VSCodeExtensions {
    Write-Output "Installing VS Code Extensions"
    try {
        code --install-extension ms-vscode-remote.remote-wsl --force; 
        code --install-extension ms-vscode.vscode-node-azure-pack --force;
        code --install-extension ms-azuretools.vscode-docker --force;
        code --install-extension ms-kubernetes-tools.vscode-aks-tools --force;
        code --install-extension ms-azuretools.vscode-apimanagement --force;
        code --install-extension VisualStudioOnlineApplicationInsights.application-insights --force;
        code --install-extension ms-dotnettools.csdevkit --force;
    } catch {
        throw "Failed to install VS Code Extensions"
    }
}

# Execute Functions
try {
    Clone-Repositories -Repositories $repositories
    Install-VSCodeExtensions
    Install-DockerDesktop
    Write-Output "Script completed successfully"
} catch {
    Write-Error $_.Exception.Message
    throw $_.Exception
}
