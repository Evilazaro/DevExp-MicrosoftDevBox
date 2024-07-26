param(
    [Parameter(Mandatory=$true, HelpMessage="Please provide the installation step number between 1 and 3.")]
    [int]$step = 1
)

Set-ExecutionPolicy Bypass -Scope Process -Force; 

function executePowerShellScript {
    param(
        [Parameter(Mandatory=$true, HelpMessage="Please provide the script content.")]
        [string]$url
    )
    
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url))
}

switch ($step) {
    1 {
        # Install winget
        executePowerShellScript -url "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/src/customizations/tasks/install-winget/installWinget.ps1"
        # Install WSL
        executePowerShellScript -url "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/src/customizations/tasks/install-wsl/installWsl.ps1"
        
    }
    2 {
        # Install Ubuntu
        executePowerShellScript -url "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/src/customizations/tasks/install-ubuntu/installUbuntu.ps1"
        # Install winget packages
        executePowerShellScript -url "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/src/customizations/tasks/install-winget-packages/installWingetPackages.ps1"
        
    }
    3 {
        # Install VS Code extensions
        executePowerShellScript -url "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/src/customizations/tasks/install-vs-extensions/installVSCodeExtensions.ps1"
        # Update .NET workloads
        executePowerShellScript -url "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/src/customizations/tasks/update-dotnet-workloads/updateDotNetWorkloads.ps1"
        # Update winget packages
        executePowerShellScript -url "https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/src/customizations/tasks/update-winget-packages/updateWingetPackages.ps1"
    }
    default {
        Write-Host "Invalid step number. Please provide a valid step number." -Level "ERROR"
    }
}