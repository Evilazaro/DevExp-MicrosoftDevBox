Set-ExecutionPolicy Bypass -Scope Process -Force;

Write-Host "Starging WSL Ubuntu installation at $(Get-Date)"

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

Write-Host "Directories Created"

$wslIntalled = $false
Write-Host "Checking if WSL is installed"
if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
    $wslIntalled = $true
    Write-Host "WSL is Intalled"
}

if (!$wslIntalled) {
    Write-Error "WSL not detected! WSL is needed to install $($packageArgs.softwareName)"
    exit 1
}


Write-Host "Downloading Scripts"
Invoke-WebRequest -Uri $("https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/Dev/Deploy/ARMTemplates/computeGallery/createUser.sh") -OutFile $($wslScriptsPth+"\createUser.sh")
Invoke-WebRequest -Uri $("https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/Dev/Deploy/ARMTemplates/computeGallery/installUtils.sh") -OutFile $($wslScriptsPth+"\installUtils.sh")
Write-Host "Scripts downloaded to $($wslScriptsPth)"

if ($automaticInstall) {
    $wslName = 'Ubuntu'
    $wslInstallationPath = "C:\Users\Default\AppData\Local\WSL2\$wslName"
    $wslUsername = "vmadmin"

   
    $date = Get-Date
    $date = $date.ToLongTimeString()
    Write-Host "Installing Ubuntu at $($date)"
    wsl --install -d Ubuntu --no-launch
    Write-Host "Ubuntu installed succesfuly at $($date)"

    # $date = Get-Date
    # $date = $date.ToLongTimeString()
    # Write-Host "Ubuntu 22.04 LTS for WSL Installed at $($date)"

    # $date = Get-Date
    # $date = $date.ToLongTimeString()
    
    # Write-Host "Creating Ubuntu User at $($date)"
    # wsl -d $wslName -u root bash -ic "/mnt/c/WSL2/scripts/createUser.sh $wslUsername ubuntu"
    
    # $date = Get-Date
    # $date = $date.ToLongTimeString()
    # Write-Host "Ubuntu User Created at $($date)"

    # $date = Get-Date
    # $date = $date.ToLongTimeString()
    # Write-Host "Updating Ubuntu Use at $($date)"
    
    # wsl -d $wslName -u root bash -ic "/mnt/c/temp/configureUbuntuFrontEnd.sh" 
    # wsl -d $wslName -u root bash -ic "DEBIAN_FRONTEND=noninteractive /mnt/c/temp/updateUbuntu.sh"

    # $date = Get-Date
    # $date = $date.ToLongTimeString()
    # Write-Host "Ubuntu Updated at $($date)"
    
    # Write-Host "Restarting WSL Distro"
    # wsl -t $wslName
    # write-host "WSL Distro Restarted"

    Write-Host "Finishing WSL Ubuntu installation at $(Get-Date)"
}
else {
    Add-AppxPackage $packageArgs.fileFullPath
}