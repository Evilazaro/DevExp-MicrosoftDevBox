
Set-ExecutionPolicy Bypass -Scope Process -Force;

function Install-WinGet {
    $progressPreference = 'silentlyContinue'
    $oFile = "c:\Downloads\"

    mkdir $oFile
    Write-Information "Downloading WinGet and its dependencies..."
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile $oFile"Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile $oFile"Microsoft.VCLibs.x64.14.00.Desktop.appx"
    Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile $oFile"Microsoft.UI.Xaml.2.8.x64.appx"
    Add-AppxPackage $oFile"Microsoft.VCLibs.x64.14.00.Desktop.appx" 
    Add-AppxPackage $oFile"Microsoft.UI.Xaml.2.8.x64.appx"
    Add-AppxPackage $oFile"Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
}

Install-WinGet