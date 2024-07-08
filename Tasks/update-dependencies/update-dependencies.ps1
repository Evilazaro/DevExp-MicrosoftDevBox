Set-ExecutionPolicy Bypass -Scope Process -Force;

# This function updates the AzureRM module
function Update-AzureRM {
    
    Install-Module -Name Az -Force -AllowClobber -Scope AllUsers -AcceptLicense    
    Write-Host "AzureRM module has been updated successfully."

}

function Install-WinGet {
  
    $PsInstallScope = "CurrentUser"
    if ($(whoami.exe) -eq "nt authority\system") {
        $PsInstallScope = "AllUsers"
    }

    Write-Host "Installing powershell modules in scope: $PsInstallScope"

    # ensure NuGet provider is installed
    if (!(Get-PackageProvider | Where-Object { $_.Name -eq "NuGet" -and $_.Version -gt "2.8.5.201" })) {
        Write-Host "Installing NuGet provider"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope $PsInstallScope
        Write-Host "Done Installing NuGet provider"
    }
    else {
        Write-Host "NuGet provider is already installed"
    }

    # Set PSGallery installation policy to trusted
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    pwsh.exe -MTA -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"

    # check if the Microsoft.Winget.Client module is installed
    if (!(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
        Write-Host "Installing Microsoft.Winget.Client"
        Install-Module Microsoft.WinGet.Client -Scope $PsInstallScope
        pwsh.exe -MTA -Command "Install-Module Microsoft.WinGet.Client -Scope $PsInstallScope"
        Write-Host "Done Installing Microsoft.Winget.Client"
    }
    else {
        Write-Host "Microsoft.Winget.Client is already installed"
    }

    # check if the Microsoft.WinGet.Configuration module is installed
    if (!(Get-Module -ListAvailable -Name Microsoft.WinGet.Configuration)) {
        Write-Host "Installing Microsoft.WinGet.Configuration"
        pwsh.exe -MTA -Command "Install-Module Microsoft.WinGet.Configuration -AllowPrerelease -Scope $PsInstallScope"
        Write-Host "Done Installing Microsoft.WinGet.Configuration"
    }
    else {
        Write-Host "Microsoft.WinGet.Configuration is already installed"
    }

    Write-Host "Updating WinGet"
    try {
        Write-Host "Attempting to repair WinGet Package Manager"
        Repair-WinGetPackageManager -Latest -Force
        Write-Host "Done Reparing WinGet Package Manager"
    }
    catch {
        Write-Host "Failed to repair WinGet Package Manager"
        Write-Error $_
    }

    if ($PsInstallScope -eq "CurrentUser") {
        $msUiXamlPackage = Get-AppxPackage -Name "Microsoft.UI.Xaml.2.8" | Where-Object { $_.Version -ge "8.2310.30001.0" }
        if (!($msUiXamlPackage)) {
            # instal Microsoft.UI.Xaml
            try {
                Write-Host "Installing Microsoft.UI.Xaml"
                $architecture = "x64"
                if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
                    $architecture = "arm64"
                }
                $MsUiXaml = "$env:TEMP\$([System.IO.Path]::GetRandomFileName())-Microsoft.UI.Xaml.2.8.6"
                $MsUiXamlZip = "$($MsUiXaml).zip"
                Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6" -OutFile $MsUiXamlZip
                Expand-Archive $MsUiXamlZip -DestinationPath $MsUiXaml
                Add-AppxPackage -Path "$($MsUiXaml)\tools\AppX\$($architecture)\Release\Microsoft.UI.Xaml.2.8.appx" -ForceApplicationShutdown
                Write-Host "Done Installing Microsoft.UI.Xaml"
            } catch {
                Write-Host "Failed to install Microsoft.UI.Xaml"
                Write-Error $_
            }
        }

        $desktopAppInstallerPackage = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller"
        if (!($desktopAppInstallerPackage) -or ($desktopAppInstallerPackage.Version -lt "1.22.0.0")) {
            # install Microsoft.DesktopAppInstaller
            try {
                Write-Host "Installing Microsoft.DesktopAppInstaller"
                $DesktopAppInstallerAppx = "$env:TEMP\$([System.IO.Path]::GetRandomFileName())-DesktopAppInstaller.appx"
                Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $DesktopAppInstallerAppx
                Add-AppxPackage -Path $DesktopAppInstallerAppx -ForceApplicationShutdown
                Write-Host "Done Installing Microsoft.DesktopAppInstaller"
            }
            catch {
                Write-Host "Failed to install DesktopAppInstaller appx package"
                Write-Error $_
            }
        }

        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Write-Host "WinGet version: $(winget -v)"
    }

    # Revert PSGallery installation policy to untrusted
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
    pwsh.exe -MTA -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted"
}

function Update-GitHubCLI {
    Write-Host "Updating GitHub CLI"
    if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "GitHub CLI is not installed. Installing GitHub CLI"
        winget install GitHub.cli --silent --accept-package-agreements --accept-source-agreements --source winget --location "US"
        Write-Host "GitHub CLI has been installed successfully."
    }
    else {
        Write-Host "GitHub CLI is already installed. Updating GitHub CLI"
        winget upgrade GitHub.cli --silent --accept-package-agreements --accept-source-agreements --source winget --location "US"
        Write-Host "GitHub CLI has been updated successfully."
    }
    
    
}

# Update Azure CLI for Developers
function Update-AzureCLI {
    if (!(Get-Command Azd -ErrorAction SilentlyContinue)) {
        Write-Host "Azure CLI is not installed. Installing Azure CLI"
        winget install -e --id Microsoft.Azd --silent --accept-package-agreements --accept-source-agreements --source winget --location "US"
        Write-Host "Azure CLI has been installed successfully."
    }
    else {
        Write-Host "Azure CLI is already installed. Updating Azure CLI"
        winget install -e --id Microsoft.Azd --silent --accept-package-agreements --accept-source-agreements --source winget --location "US"
        Write-Host "Azure CLI has been updated successfully."
    }
}

# Update dotnet frmeowrk
function Update-DotNet {
    Write-Host "Updating .NET Framework"
    dotnet workload update
    Write-Host ".NET Framework has been updated successfully."
}

# This function updates all the dependencies
function Update-Dependencies {
    Install-WinGet
    Update-AzureCLI
    Update-GitHubCLI
    Update-AzureRM
    Update-DotNet
}

# The main function that updates all dependencies

Update-Dependencies
