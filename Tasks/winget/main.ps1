Set-ExecutionPolicy Bypass -Scope Process -Force;

# Install the Windows Package Manager
Write-Host "Installing the Windows Package Manager..."

mkdir "c:\Downloads"
# Set the path for the installer
$installerPath = "c:\Downloads\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.Msixbundle"

# Download the App Installer package
Invoke-WebRequest -Uri "https://aka.ms/Microsoft-DesktopAppInstaller" -OutFile $installerPath

# Install the App Installer package
Add-AppxPackage -Path $installerPath

# Verify the installation
winget --version

Write-Host "Windows Package Manager installed successfully!"
