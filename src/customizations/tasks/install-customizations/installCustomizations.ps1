param(
    [Parameter(Mandatory=$true, HelpMessage="Please provide the installation step number between 1 and 3.")]
    [int]$step = 1
)

Set-ExecutionPolicy Bypass -Scope Process -Force; 
# Parameter help description


function UpdateDotNetWorkloads {
    try {

        Write-Host "Updating Dotnet workloads..."
        dotnet workload update
        Write-Host "Workloads have been completed successfully."

    }
    catch {
        Write-Host "Failed to update Dotnet workloads: $_"  -Level "ERROR"
    }
}

function InstallVSCodeExtensions {
    try {
        Write-Host "Installing VSCode extensions..."

        $extensions = @(
            "ms-vscode-remote.remote-wsl",
            "ms-vscode.PowerShell",
            "ms-vscode.vscode-node-azure-pack",
            "GitHub.copilot",
            "GitHub.vscode-pull-request-github",
            "GitHub.copilot-chat",
            "GitHub.remotehub",
            "GitHub.vscode-github-actions",
            "eamodio.gitlens-insiders",
            "ms-vscode.azure-repos",
            "ms-azure-devops.azure-pipelines",
            "ms-azuretools.vscode-docker",
            "ms-kubernetes-tools.vscode-kubernetes-tools",
            "ms-kubernetes-tools.vscode-aks-tools",
            "ms-azuretools.vscode-azurecontainerapps",
            "ms-azuretools.vscode-azurefunctions",
            "ms-azuretools.vscode-apimanagement"
        )

        foreach ($extension in $extensions) {
            code --install-extension $extension --force
        }

        Write-Host "VSCode extensions have been installed successfully."
    }
    catch {
        Write-Host "Failed to install VSCode extensions: $_" -Level "ERROR"
    }
}

function installUbuntu{
    # Check if winget is installed
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget is installed. Proceeding with Ubuntu installation..."

        # Install Ubuntu
        winget install -e --id 9PDXGNCFSCZV --source winget --accept-package-agreements --accept-source-agreements --silent

        Write-Host "Ubuntu installation initiated."
    }
    else {
        Write-Error "winget is not installed. Please install it from the Microsoft Store."
    }

}

function installWsl{
    # Check if winget is installed
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget is installed. Proceeding with WSL installation..."

        # Install Ubuntu
        winget install -e --id Microsoft.WSL --source winget --accept-package-agreements --accept-source-agreements --silent

        Write-Host "WSL installation initiated."
    }
    else {
        Write-Error "winget is not installed. Please install it from the Microsoft Store."
    }

}

function updateWingetPackages {
    try {
        Write-Host "Updating winget packages..."
        winget upgrade --all --accept-package-agreements --accept-source-agreements --source winget
        Write-Host "Packages have been updated successfully."
    }
    catch {
        Write-Host "Failed to update winget packages: $_"  -Level "ERROR"
    }
}

function importWingetPackages {
    try {
        Write-Host "Importing winget packages... Please have a sit and relax."
        winget import -i ..\install-winget-packages\devMachineConfig.json
        Write-Host "Packages have been imported successfully."
    }
    catch {
        Write-Host "Failed to import winget packages: $_"  -Level "ERROR"
    }
}

function restartComputer{
    Write-Host "Restarting the computer in 10 seconds..."
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}

function InstallWinGet {
    Write-Host "Installing powershell modules in scope: $PsInstallScope"

    $PsInstallScope="AllUsers"

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

    # check if the Microsoft.Winget.Client module is installed
    if (!(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
        Write-Host "Installing Microsoft.Winget.Client"
        Install-Module Microsoft.WinGet.Client -Scope $PsInstallScope
        Write-Host "Done Installing Microsoft.Winget.Client"
    }
    else {
        Write-Host "Microsoft.Winget.Client is already installed"
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

    if ($PsInstallScope -eq "AllUsers") {
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
}

switch ($step) {
    1 {
        InstallWinGet
        installWsl
    }
    2 {
        installUbuntu
        importWingetPackages
    }
    3 {
        InstallVSCodeExtensions
        UpdateDotNetWorkloads   
        updateWingetPackages 
    }
    default {
        Write-Host "Invalid step number. Please provide a valid step number." -Level "ERROR"
    }
}

