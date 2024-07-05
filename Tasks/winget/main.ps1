
function Install-WinGet {
    $actionTaken = $false
    # check if the Microsoft.Winget.Client module is installed
    if (!(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
        Write-Host "Installing Microsoft.Winget.Client"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

        Install-Module WinGet -Scope AllUsers -Force
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