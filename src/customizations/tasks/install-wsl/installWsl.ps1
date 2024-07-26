Set-ExecutionPolicy Bypass -Scope Process -Force; 

function installWsl{
    # Check if winget is installed
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget is installed. Proceeding with WSL installation..."

        # Install Ubuntu
        wsl install --force

        Write-Host "WSL installation initiated."
    }
    else {
        Write-Error "winget is not installed. Please install it from the Microsoft Store."
    }

}

installWsl