Set-ExecutionPolicy Bypass -Scope Process -Force; 

function installWingetPackages {
    try {
        Write-Host "Importing winget packages... Please have a sit and relax."
        winget import -i .\devMachineConfig.json
        Write-Host "Packages have been imported successfully."
    }
    catch {
        Write-Host "Failed to import winget packages: $_"  -Level "ERROR"
    }
}

installWingetPackages