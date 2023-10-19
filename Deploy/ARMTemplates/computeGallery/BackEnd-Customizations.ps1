
# Set the execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

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

function installAzureADModules{
    Write-Output "Installing Azure AD Modules"
    try {
        Install-Module -Name AzureAD -Force -SkipPublisherCheck
    } catch {
        throw "Failed to install Azure AD Modules"
    }
}

# Execute Functions
try {
    Install-DockerDesktop
    Write-Output "Script completed successfully"
} catch {
    Write-Error $_.Exception.Message
    throw $_.Exception
}
