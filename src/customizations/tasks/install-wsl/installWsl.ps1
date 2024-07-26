Set-ExecutionPolicy Bypass -Scope Process -Force; 

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

installWsl