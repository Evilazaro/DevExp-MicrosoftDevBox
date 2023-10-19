# Set the execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

function installDockerDesktop {
    param (
        [string]$dockerDownloadUrl = 'https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe',
        [string]$dockerTempFolderPath = 'c:\DockerTemp',
        [string]$installerFileName = 'dockerInstall.exe'
    )

    Write-Output "Installing Docker Desktop"

    try {
        if (-not (Test-Path $dockerTempFolderPath)) {
            New-Item -ItemType Directory -Path $dockerTempFolderPath
        }

        $installerFullPath = Join-Path $dockerTempFolderPath $installerFileName

        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($dockerDownloadUrl, $installerFullPath)

        & $installerFullPath install --wait --quiet --accept-license

        Write-Output "Docker Desktop installed successfully"
    } catch {
        throw "Failed to install Docker Desktop: $_"
    }
}

function installAzureADModules {
    try {
        Write-Output "Installing Azure AD Modules"
        Install-Module -Name AzureAD -Force -SkipPublisherCheck
    } catch {
        throw "Failed to install Azure AD Modules: $_"
    }
}

# Execute Functions
try {
    installDockerDesktop
    installAzureADModules
    Write-Output "Script completed successfully"
} catch {
    Write-Error $_.Exception.Message
    throw $_.Exception
}
