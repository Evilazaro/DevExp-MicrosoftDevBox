Set-ExecutionPolicy Bypass -Scope Process -Force; 

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

updateWingetPackages