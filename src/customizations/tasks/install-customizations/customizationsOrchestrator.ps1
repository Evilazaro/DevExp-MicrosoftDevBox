param(
    [Parameter(Mandatory=$true, HelpMessage="Please provide the installation step number between 1 and 3.")]
    [int]$step = 1
)

Set-ExecutionPolicy Bypass -Scope Process -Force; 

switch ($step) {
    1 {
        .\install-winget\installWinget.ps1
        .\install-wsl\isntallWsl.ps1
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