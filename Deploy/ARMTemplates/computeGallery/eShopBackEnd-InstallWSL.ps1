cls
Set-ExecutionPolicy Bypass -Scope Process -Force;

wsl --unregister Ubuntu

$ErrorActionPreference = 'Stop'

$automaticInstall = $true
$wslRootPath = "c:\WSL2"
$wslTempPath = $wslRootPath+"\temp"
$wslStagingPath = $wslTempPath+"\staging"
$wslScriptsPth = $wslRootPath+"\scripts"

Write-Host "Creating Directories"

mkdir $wslRootPath
mkdir $wslTempPath
mkdir $wslStagingPath
mkdir $wslScriptsPth

$packageArgs = @{
    packageName    = 'wsl-ubuntu-2204'
    softwareName   = 'Ubuntu 22.04 LTS for WSL'
    checksum       = 'c5028547edfe72be8f7d44ef52cee5aacaf9b1ae1ed4f7e39b94dae3cf286bc2'
    checksumType   = 'sha256'
    url            = 'https://wsl2.blob.core.windows.net/ubuntu/Ubuntu2204-221101.AppxBundle'
    fileFullPath   = "$wslTempPath\ubuntu2204.appx"
    validExitCodes = @(0)
}

$wslIntalled = $false
Write-Host "Checking if WSL is installed"
if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
    $wslIntalled = $true
}

if (!$wslIntalled) {
    Write-Error "WSL not detected! WSL is needed to install $($packageArgs.softwareName)"
    exit 1
}

Write-Host "Downloading $($packageArgs.softwareName)"

# Download Docker Desktop Installer
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($($packageArgs.url), $($packageArgs.fileFullPath))

Write-Host "$($packageArgs.softwareName) downloaded to $($packageArgs.fileFullPath)"

Write-Host "Downloading Scripts"
Invoke-WebRequest -Uri $("https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/Dev/Deploy/ARMTemplates/computeGallery/createUser.sh") -OutFile $($wslScriptsPth+"\createUser.sh")
Invoke-WebRequest -Uri $("https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/Dev/Deploy/ARMTemplates/computeGallery/installUtils.sh") -OutFile $($wslScriptsPth+"\installUtils.sh")
Write-Host "Scripts downloaded to $($wslScriptsPth)"

if ($automaticInstall) {
    $wslName = 'Ubuntu'
    $wslInstallationPath = "c:\WSL2\$wslName"
    $wslUsername = "ubuntu-usr"

    # create staging directory if it does not exists
    if (-Not (Test-Path -Path $wslTempPath\staging)) { $dir = mkdir $wslTempPath\staging }

    Move-Item $wslTempPath\ubuntu2204.appx $wslTempPath\staging\$wslName-Temp.zip

    Expand-Archive $wslTempPath\staging\$wslName-Temp.zip $wslTempPath\staging\$wslName-Temp

    Move-Item $wslTempPath\staging\$wslName-Temp\Ubuntu_2204.1.7.0_x64.appx $wslTempPath\staging\$wslName.zip

    Expand-Archive $wslTempPath\staging\$wslName.zip $wslTempPath\staging\$wslName

    if (-Not (Test-Path -Path $wslInstallationPath)) {
        mkdir $wslInstallationPath
    }

    Write-Host "Importing/Installing WSL"
    wsl --import $wslName $wslInstallationPath $wslTempPath\staging\$wslName\install.tar.gz

    Move-Item $wslTempPath\staging\$wslName-Temp.zip $wslTempPath\ubuntu2204.appx 
    Remove-Item -r $wslTempPath\staging\
    
    Write-Host "Ubuntu 22.04 LTS for WSL Installed"

    Write-Host "Creating Ubuntu User"
    # # create your user and add it to sudoers
    wsl -d $wslName -u root bash -ic "/mnt/c/WSL2/scripts/createUser.sh $wslUsername ubuntu"
    Write-Host "Ubuntu User Created"
    
    # # ensure WSL Distro is restarted when first used with user account
    Write-Host "Restarting WSL Distro"
    wsl -t $wslName
}
else {
    Add-AppxPackage $packageArgs.fileFullPath
}