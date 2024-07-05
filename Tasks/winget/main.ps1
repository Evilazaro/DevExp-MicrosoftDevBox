
function Install-WinGet {
    $actionTaken = $false

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

    # check if the Microsoft.Winget.Client module is installed
    if (!(Get-Module -ListAvailable -Name Winget)) {
        Write-Host "Installing Winget"        

        Install-Module WinGet -Scope AllUsers -Force

        Write-Host "Done Installing Winget"
        $actionTaken = $true
    }
    else
    {
        Write-Host "Winget is already installed"
    }

    if (!(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
        Write-Host "Installing Microsoft.Winget.Client"
        
        Install-Module Microsoft.WinGet.Client -Scope AllUsers -Force

        Write-Host "Done Installing Microsoft.Winget.Client"
        $actionTaken = $true
    }
    else {
        Write-Host "Microsoft.Winget.Client is already installed"
    }

    return $actionTaken
}

Install-WinGet