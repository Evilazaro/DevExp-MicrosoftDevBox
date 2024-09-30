$CustomizationScriptsDir = "C:\DevBoxCustomizationsPwsh"
$LockFile = "lockfile"
$RunAsUserScript = "runAsUser.ps1"
$CleanupScript = "cleanup.ps1"
$RunAsUserTask = "DevBoxCustomizationsPwsh"
$CleanupTask = "DevBoxCustomizationsPwshCleanup"

# Set the progress preference to silently continue
# in order to avoid progress bars in the output
# as this makes web requests very slow
# Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables
$ProgressPreference = 'SilentlyContinue'

Start-Transcript -Path $env:TEMP\scheduled-task-customization-pwsh.log -Append -IncludeInvocationHeader

Write-Host "Microsoft Dev Box - Customizations"
Write-Host "----------------------------------"
Write-Host "Setting up scheduled tasks..."

Remove-Item -Path "$($CustomizationScriptsDir)\$($LockFile)"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")


