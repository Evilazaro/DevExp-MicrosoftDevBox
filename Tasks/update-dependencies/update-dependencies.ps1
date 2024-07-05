Set-ExecutionPolicy Bypass -Scope Process -Force;

# This function updates the AzureRM module
function Update-AzureRM {
    # Check if AzureRM module is installed
    if (Get-Module -ListAvailable -Name AzureRM) {
        # Update AzureRM module
        Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser
        Write-Host "AzureRM module has been updated successfully."
    }
    else {
        Write-Host "AzureRM module is not installed. Please install it before running this function."
    }
}

# This function updates the GitHub CLI
function Update-GitHubCLI {
    # Check if GitHub CLI is installed
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        # Update GitHub CLI
        gh upgrade --yes
        Write-Host "GitHub CLI has been updated successfully."
    }
    else {
        Write-Host "GitHub CLI is not installed. Please install it before running this function."
    }
}

# This function updates the Azure Developer CLI
function Update-AzureDeveloperCLI {
    # Check if Azure Developer CLI is installed
    if (Get-Command azdev -ErrorAction SilentlyContinue) {
        # Update Azure Developer CLI
        azdev upgrade --yes
        Write-Host "Azure Developer CLI has been updated successfully."
    }
    else {
        Write-Host "Azure Developer CLI is not installed. Please install it before running this function."
    }
}
function Install-WinGet {
    Write-Host "Start to install WinGet"

}

function Update-DotNet {
    Write-Host "Start to update .NET"
    dotnet workload update --ignore-failed-sources --from-previous-sdk
    Write-Host "End to update .NET"
}

# This function updates all the dependencies
function Update-Dependencies {
    Update-DotNet
    Install-WinGet
    Update-AzureCLI
    Update-AzureRM
    Update-GitHubCLI
    Update-AzureDeveloperCLI
}

# The main function that updates all dependencies

Update-Dependencies
