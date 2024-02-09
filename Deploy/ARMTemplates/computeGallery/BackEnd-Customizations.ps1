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

function intallVSCode {
    
    Write-Output "Installing Visual Studio Code"   
    try {
        
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        
        choco install vscode

        Write-Output "Visual Studio Code installed successfully"
    } catch {
        throw "Failed to install Visual Studio Code: $_"
    }
}

# Execute Functions
try {
    intallVSCode
    installDockerDesktop
    Write-Output "Script completed successfully"
} catch {
    Write-Error $_.Exception.Message
    throw $_.Exception
}
