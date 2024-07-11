# Set the execution policy for the current process to bypass (allows the script to run without restrictions)
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force
} catch {
    Write-Error "Failed to set execution policy: $_"
    exit 1
}

# Define the URL to download Postman (update this URL if necessary)
$PostmanUrl = "https://dl.pstmn.io/download/latest/win64"

# Define the path where Postman will be downloaded
$DownloadPath = Join-Path -Path $env:TEMP -ChildPath "Postman.exe"

# Function to download Postman installer
function Invoke-PostmanDownload {
    param (
        [string]$Url,
        [string]$OutputPath
    )
    
    try {
        Write-Host "Downloading Postman from $Url..."
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -ErrorAction Stop
        Write-Host "Download completed successfully."
    } catch {
        Write-Error "Failed to download Postman: $_"
        exit 1
    }
}

# Function to install Postman silently
function Install-Postman {
    param (
        [string]$InstallerPath
    )
    
    try {
        Write-Host "Installing Postman..."
        Start-Process -FilePath $InstallerPath -ArgumentList "/S" -Wait -ErrorAction Stop
        Write-Host "Postman installed successfully."
    } catch {
        Write-Error "Failed to install Postman: $_"
        exit 1
    }
}

# Main script execution
Invoke-PostmanDownload -Url $PostmanUrl -OutputPath $DownloadPath
Install-Postman -InstallerPath $DownloadPath
