$CustomizationScriptsDir = "C:\DevBoxCustomizationsPwsh"
$LockFile = "lockfile"
$RunAsUserScript = "runAsUser.ps1"
$CleanupScript = "cleanup.ps1"
$RunAsUserTask = "DevBoxCustomizationsPwsh"
$CleanupTask = "DevBoxCustomizationsPwshCleanup"

if (!(Test-Path "$($CustomizationScriptsDir)\$($LockFile)")) {
    Unregister-ScheduledTask -TaskName $RunAsUserTask -Confirm:$false
    Unregister-ScheduledTask -TaskName $CleanupTask -Confirm:$false
    Remove-Item $CustomizationScriptsDir -Force -Recurse
}
