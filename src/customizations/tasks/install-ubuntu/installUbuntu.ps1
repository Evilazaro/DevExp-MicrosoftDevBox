Set-ExecutionPolicy Bypass -Scope Process -Force; 

function installUbuntu{
    # Check if winget is installed
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget is installed. Proceeding with Ubuntu installation..."

        # Install Ubuntu
        winget install -e --id 9PDXGNCFSCZV --source winget --accept-package-agreements --accept-source-agreements --silent

        Write-Host "Ubuntu installation initiated."
    }
    else {
        Write-Error "winget is not installed. Please install it from the Microsoft Store."
    }

}

installUbuntu