Set-ExecutionPolicy Bypass -Scope Process -Force

$PsInstallScope = "AllUsers"

function Install-WinGet {
    Write-Host "Installing PowerShell modules in scope: $PsInstallScope"

    # Ensure NuGet provider is installed
    try {
        if (!(Get-PackageProvider | Where-Object { $_.Name -eq "NuGet" -and $_.Version -gt "2.8.5.201" })) {
            Write-Host "Installing NuGet provider"
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope $PsInstallScope
            Write-Host "NuGet provider installed"
        } else {
            Write-Host "NuGet provider is already installed"
        }
    } catch {
        Write-Error "Failed to install NuGet provider: $_"
    }

    # Set PSGallery installation policy to trusted
    try {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    } catch {
        Write-Error "Failed to set PSGallery installation policy to Trusted: $_"
    }

    # Install Microsoft.WinGet.Client if not installed
    try {
        if (-not (Get-Module -ListAvailable -Name Microsoft.WinGet.Client)) {
            Write-Host "Installing Microsoft.WinGet.Client"
            Install-Module -Name Microsoft.WinGet.Client -Scope $PsInstallScope -Force
            Write-Host "Microsoft.WinGet.Client installed"
        } else {
            Write-Host "Microsoft.WinGet.Client is already installed"
        }
    } catch {
        Write-Error "Failed to install Microsoft.WinGet.Client: $_"
    }

    # Install Microsoft.WinGet.Configuration if not installed
    try {
        if (-not (Get-Module -ListAvailable -Name Microsoft.WinGet.Configuration)) {
            Write-Host "Installing Microsoft.WinGet.Configuration"
            Install-Module -Name Microsoft.WinGet.Configuration -AllowPrerelease -Scope $PsInstallScope -Force
            Write-Host "Microsoft.WinGet.Configuration installed"
        } else {
            Write-Host "Microsoft.WinGet.Configuration is already installed"
        }
    } catch {
        Write-Error "Failed to install Microsoft.WinGet.Configuration: $_"
    }

    # Attempt to repair WinGet Package Manager
    try {
        Write-Host "Attempting to repair WinGet Package Manager"
        Repair-WinGetPackageManager -Latest -Force
        Write-Host "WinGet Package Manager repaired"
    } catch {
        Write-Error "Failed to repair WinGet Package Manager: $_"
    }

    # Install Microsoft.UI.Xaml if necessary
    if ($PsInstallScope -eq "AllUsers") {
        try {
            $msUiXamlPackage = Get-AppxPackage -Name "Microsoft.UI.Xaml.2.8" | Where-Object { $_.Version -ge "8.2310.30001.0" }
            if (-not $msUiXamlPackage) {
                Write-Host "Installing Microsoft.UI.Xaml"
                $architecture = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
                $MsUiXamlZip = Join-Path $env:TEMP "$([System.IO.Path]::GetRandomFileName())-Microsoft.UI.Xaml.2.8.6.zip"
                Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6" -OutFile $MsUiXamlZip
                $MsUiXaml = [System.IO.Path]::GetDirectoryName($MsUiXamlZip)
                Expand-Archive $MsUiXamlZip -DestinationPath $MsUiXaml
                Add-AppxPackage -Path "$MsUiXaml\tools\AppX\$architecture\Release\Microsoft.UI.Xaml.2.8.appx" -ForceApplicationShutdown
                Write-Host "Microsoft.UI.Xaml installed"
            } else {
                Write-Host "Microsoft.UI.Xaml is already installed"
            }
        } catch {
            Write-Error "Failed to install Microsoft.UI.Xaml: $_"
        }

        # Install Microsoft.DesktopAppInstaller if necessary
        try {
            $desktopAppInstallerPackage = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller"
            if (-not $desktopAppInstallerPackage -or $desktopAppInstallerPackage.Version -lt "1.22.0.0") {
                Write-Host "Installing Microsoft.DesktopAppInstaller"
                $DesktopAppInstallerAppx = Join-Path $env:TEMP "$([System.IO.Path]::GetRandomFileName())-DesktopAppInstaller.appx"
                Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $DesktopAppInstallerAppx
                Add-AppxPackage -Path $DesktopAppInstallerAppx -ForceApplicationShutdown
                Write-Host "Microsoft.DesktopAppInstaller installed"
            } else {
                Write-Host "Microsoft.DesktopAppInstaller is already installed"
            }
        } catch {
            Write-Error "Failed to install Microsoft.DesktopAppInstaller: $_"
        }

        # Update environment path
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Host "WinGet version: $(winget -v)"
    }

    # Revert PSGallery installation policy to untrusted
    try {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
    } catch {
        Write-Error "Failed to revert PSGallery installation policy to Untrusted: $_"
    }
}

function Install-Customizations {
    Install-WinGet
    $customFileName = "customizations.json"
    $folder = "C:\downloads"
    try {
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        $customFileFullPath = Join-Path $folder $customFileName
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Tasks/install-customizations/customizations.json" -OutFile $customFileFullPath
        winget import -i $customFileFullPath --ignore-unavailable --accept-package-agreements --accept-source-agreements --verbose --disable-interactivity
        Write-Host "Customizations imported successfully"
    } catch {
        Write-Error "Failed to import customizations: $_"
    }
}

Install-Customizations
