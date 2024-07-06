Set-ExecutionPolicy Bypass -Scope Process -Force;

# This function updates the AzureRM module
function Update-AzureRM {
    
    Install-Module -Name Az -Force -AllowClobber -Scope AllUsers -AcceptLicense    
    Write-Host "AzureRM module has been updated successfully."

}

# This function updates the GitHub CLI
function Update-GitHubCLI {
    # Check if GitHub CLI is installed
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        # Update GitHub CLI
        Write-Host "GitHub CLI is already installed. Updating it now."
        winget upgrade --id GitHub.cli -e --silent --accept-package-agreements --accept-source-agreements --location "US"
        Write-Host "GitHub CLI has been updated successfully."
    }
    else {
        Write-Host "GitHub CLI is not installed. Installing it now."
        winget install --id GitHub.cli -e --silent --accept-package-agreements --accept-source-agreements --location "US"
        Write-Host "GitHub CLI has been installed successfully."
    }
}

# This function updates the Azure Developer CLI
function Update-AzureDeveloperCLI {
    # Check if Azure Developer CLI is installed
    if (Get-Command azd -ErrorAction SilentlyContinue) {
        # Update Azure Developer CLI
        Write-Host "Azure Developer CLI is already installed. Updating it now."
        winget upgrade --id Microsoft.Azd -e --silent --accept-package-agreements --accept-source-agreements --location "US"
        Write-Host "Azure Developer CLI has been updated successfully."
    }
    else {
        Write-Host "Azure Developer CLI is not installed. Installing it now."
        winget install --id Microsoft.Azd -e --silent --accept-package-agreements --accept-source-agreements --location "US"
        Write-Host "Azure Developer CLI has been installed successfully."
    }
}

function Update-DotNet {
    Write-Host "Start to update .NET"
    dotnet workload update
    Write-Host "End to update .NET"
}

function Install-WinGet {
    # Check if WinGet is installed
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "WinGet is already installed."
    }
    else {
        Write-Host "WinGet is not installed. Installing it now."
        $progressPreference = 'silentlyContinue'
        Write-Information "Downloading WinGet and its dependencies..."
        Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx
        Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
        Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
        Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
        Write-Host "WinGet has been installed successfully."
    }
}

# This function updates all the dependencies
function Update-Dependencies {
    Install-WinGet
    Update-AzureRM
    Update-GitHubCLI
    Update-AzureDeveloperCLI
    Update-DotNet    
}

# The main function that updates all dependencies

Update-Dependencies
