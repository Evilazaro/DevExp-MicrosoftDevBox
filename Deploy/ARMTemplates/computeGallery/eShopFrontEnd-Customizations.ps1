<#
.SYNOPSIS
This script clones repositories, installs Docker Desktop, and VS Code Extensions.

.DESCRIPTION
The script performs the following actions:
- Sets the execution policy to Bypass for the process scope.
- Clones the specified repositories to the specified destinations.
- Installs Docker Desktop using Chocolatey.
- Installs specified VS Code Extensions.
#>

# Set the execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Execute Functions
try {
    .\cloneRepos.ps1
    Write-Output "Script completed successfully"
} catch {
    Write-Error $_.Exception.Message
    throw $_.Exception
}
