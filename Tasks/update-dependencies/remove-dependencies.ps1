Set-ExecutionPolicy Bypass -Scope Process -Force;

# This function uninstalls the AzureRM module
function Uninstall-AzureRM {
    # Check if AzureRM module is installed
    if (Get-Command az -ErrorAction SilentlyContinue) {
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
        winget uninstall --id GitHub.cli -e --silent 
        Write-Host "GitHub CLI has been uninstalled successfully."
    }
    else {
        Write-Host "GitHub CLI is not installed."
    }
}

# This function uninstalls the Azure Developer CLI
function Uninstall-AzureDeveloperCLI {
    # Check if Azure Developer CLI is installed
    if (Get-Command azd -ErrorAction SilentlyContinue) {
        # Uninstall Azure Developer CLI
        winget uninstall --id Microsoft.Azd -e --silent 
        Write-Host "Azure Developer CLI has been uninstalled successfully."
    }
    else {
        Write-Host "Azure Developer CLI is not installed."
    }
}


# This function uninstalls WinGet (if possible)
function Uninstall-WinGet {
    # Check if WinGet is installed
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "WinGet is installed. Uninstalling it now."
        Remove-Module -Name Winget -Force
        Remove-Module -Name Microsoft.Winget.Client -Force
    }
    else {
        Write-Host "WinGet is not installed."
    }
}

# This function uninstalls all the dependencies
function Uninstall-Dependencies {   
    Uninstall-AzureRM
    Uninstall-GitHubCLI
    Uninstall-AzureDeveloperCLI
    Uninstall-WinGet
}

# The main function that uninstalls all dependencies

Uninstall-Dependencies
