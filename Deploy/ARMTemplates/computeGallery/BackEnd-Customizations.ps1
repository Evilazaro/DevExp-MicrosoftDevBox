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

        & $installerFullPath install --wait --quiet --accept-license /S /allusers

        Write-Output "Docker Desktop installed successfully"
    } catch {
        throw "Failed to install Docker Desktop: $_"
    }
}

function installKubernetesTools {
    
    param (
        [string]$lensDownloadUrl = 'https://api.k8slens.dev/binaries/Lens%20Setup%202023.10.181418-latest.exe',
        [string]$lensTempFolderPath = 'c:\DockerTemp',
        [string]$installerFileName = 'lensInstall.exe'
    )
    
    try {
        Write-Output "Installing Kubernetes Tools"
        
        if (-not (Test-Path $lensTempFolderPath)) {
            New-Item -ItemType Directory -Path $lensTempFolderPath
        }

        $installerFullPath = Join-Path $lensTempFolderPath $installerFileName

        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($lensDownloadUrl, $installerFullPath)

        & $installerFullPath install --wait --quiet --accept-license /S /allusers

        Write-Output "Kubernetes Tools installed successfully"
    } catch {
        throw "Failed to install Kubernetes Tools: $_"
    }
}

# Execute Functions
try {
    installDockerDesktop
    installKubernetesTools
    Write-Output "Script completed successfully"
} catch {
    Write-Error $_.Exception.Message
    throw $_.Exception
}
