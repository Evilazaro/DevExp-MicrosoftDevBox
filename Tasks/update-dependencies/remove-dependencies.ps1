Set-ExecutionPolicy Bypass -Scope Process -Force;

# This function uninstalls the AzureRM module
function Uninstall-AzureRM {
    # Check if AzureRM module is installed
    if (Get-Module -ListAvailable -Name AzureRM) {
        # Uninstall AzureRM module
        Uninstall-Module -Name Az -Force
        Write-Host "AzureRM module has been uninstalled successfully."
    }
    else {
        Write-Host "AzureRM module is not installed."
    }
}

# This function uninstalls the GitHub CLI
function Uninstall-GitHubCLI {
    # Check if GitHub CLI is installed
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        # Uninstall GitHub CLI
        winget uninstall --id GitHub.cli -e --silent --accept-package-agreements --accept-source-agreements
        Write-Host "GitHub CLI has been uninstalled successfully."
    }
    else {
        Write-Host "GitHub CLI is not installed."
    }
}

# This function uninstalls the Azure Developer CLI
function Uninstall-AzureDeveloperCLI {
    # Check if Azure Developer CLI is installed
    if (Get-Command azdev -ErrorAction SilentlyContinue) {
        # Uninstall Azure Developer CLI
        winget uninstall --id Microsoft.Azd -e --silent --accept-package-agreements --accept-source-agreements
        Write-Host "Azure Developer CLI has been uninstalled successfully."
    }
    else {
        Write-Host "Azure Developer CLI is not installed."
    }
}

# This function uninstalls the .NET workloads
function Uninstall-DotNet {
    Write-Host "Start to uninstall .NET workloads"
    dotnet workload uninstall --all
    Write-Host "End to uninstall .NET workloads"
}

# This function uninstalls WinGet (if possible)
function Uninstall-WinGet {
    # Check if WinGet is installed
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "WinGet is installed. Uninstalling it now."
        winget uninstall --id Microsoft.Winget.Client -e --silent --accept-package-agreements --accept-source-agreements
    }
    else {
        Write-Host "WinGet is not installed."
    }
}

# This function uninstalls all the dependencies
function Uninstall-Dependencies {
    Uninstall-WinGet
    Uninstall-DotNet    
    Uninstall-AzureRM
    Uninstall-GitHubCLI
    Uninstall-AzureDeveloperCLI
}

# The main function that uninstalls all dependencies

Uninstall-Dependencies
