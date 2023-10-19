Set-ExecutionPolicy Bypass -Scope Process -Force

function WriteTimestampedMessage {
    param (
        [string]$message
    )

    $currentTime = Get-Date
    Write-Host "$message at $($currentTime.ToLongTimeString())"
}

function EnsureDirectory {
    param (
        [string]$path
    )

    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory | Out-Null
    }
}

function DownloadScript {
    param (
        [string]$uri,
        [string]$destinationPath
    )

    Invoke-WebRequest -Uri $uri -OutFile $destinationPath
}

# Main Script Execution

WriteTimestampedMessage "Starting WSL Ubuntu installation"

$automaticInstall = $true
$wslRootPath = "c:\WSL2"
$wslTempPath = Join-Path $wslRootPath "temp"
$wslStagingPath = Join-Path $wslTempPath "staging"
$wslScriptsPath = Join-Path $wslRootPath "scripts"

Write-Host "Creating Directories"
EnsureDirectory $wslRootPath
EnsureDirectory $wslTempPath
EnsureDirectory $wslStagingPath
EnsureDirectory $wslScriptsPath
Write-Host "Directories Created"

$wslInstalled = (Get-Command wsl.exe -ErrorAction SilentlyContinue) -ne $null

if ($wslInstalled) {
    Write-Host "WSL is Installed"
} else {
    Write-Error "WSL not detected! WSL is needed to install."
    exit 1
}

Write-Host "Downloading Scripts"
DownloadScript "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/computeGallery/createUser.sh" (Join-Path $wslScriptsPath "createUser.sh")
DownloadScript "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/computeGallery/installUtils.sh" (Join-Path $wslScriptsPath "installUtils.sh")
Write-Host "Scripts downloaded to $wslScriptsPath"

if ($automaticInstall) {
    $wslName = 'Ubuntu'
    $wslInstallationPath = "C:\Users\Default\AppData\Local\WSL2\$wslName"
    $wslUsername = "vmadmin"

    WriteTimestampedMessage "Installing Ubuntu"
    wsl --install -d Ubuntu -u root -y
    WriteTimestampedMessage "Ubuntu installed successfully"

    # Commented out sections can be uncommented if needed.
    # WriteTimestampedMessage "Creating Ubuntu User"
    # wsl -d $wslName -u root bash -ic "/mnt/c/WSL2/scripts/createUser.sh $wslUsername ubuntu"
    # WriteTimestampedMessage "Ubuntu User Created"
    # WriteTimestampedMessage "Updating Ubuntu User"
    # wsl -d $wslName -u root bash -ic "/mnt/c/temp/configureUbuntuFrontEnd.sh"
    # wsl -d $wslName -u root bash -ic "DEBIAN_FRONTEND=noninteractive /mnt/c/temp/updateUbuntu.sh"
    # WriteTimestampedMessage "Ubuntu Updated"
    # Write-Host "Restarting WSL Distro"
    # wsl -t $wslName
    # Write-Host "WSL Distro Restarted"
    WriteTimestampedMessage "Finishing WSL Ubuntu installation"
} else {
    Add-AppxPackage $packageArgs.fileFullPath
}
