#Postman.perMachine
#v1.8
Function ConvertTo-LocalApplication {
  param($ApplicationName,
    $SourcePath,
    $SourceExe,
    $DestinationShortcut,
    $DestinationStartMenu
  )
  Function Set-Shortcut {
    param($SourceExe, $DestinationShortcut)
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($DestinationShortcut)
    $Shortcut.TargetPath = $SourceExe
    $Shortcut.Save()
  }
  Try {
      If ((Test-path "${env:SystemDrive}\$ApplicationName") -eq $True) { Remove-Item "${env:SystemDrive}\$ApplicationName" -Recurse -Force}
    New-Item -Name $ApplicationName -ItemType Directory -Path "${env:SystemDrive}\" -Force
    Copy-Item "$SourcePath\*" -Destination "${env:SystemDrive}\$ApplicationName" -Recurse -Force
    Write-Output "${env:SystemDrive}\$ApplicationName ===>>> folder created!"
  }
  Catch {
    Write-Output "Unable to create/copy the folder to the C:\"
  }
  Try {
    Set-Shortcut -SourceExe "$SourceExe" -DestinationShortcut "$DestinationShortcut"
    Copy-Item $DestinationShortcut -Destination $DestinationStartMenu -Recurse -Force
    Write-Output "${env:Public}\Desktop\$ApplicationName.lnk ===>>> shortcut created!"
  }
  Catch {
    Write-Output "Unable to create shortcut"
    Exit 555
  }
Exit 0
}
#housekeep user left overs
Function Remove-LocalPostman {
    param($PostmanUserPath, $Username)	
    & $PostmanUserPath --uninstall -s
    Start-Sleep -Seconds 5
    Remove-Item "C:\users\$Username\AppData\Local\Postman" -Recurse -Force 
 }
#######################################
$ApplicationName = 'Postman' # <<<=== Your ApplicationName here
#######################################
$Chocolocal = Get-ChildItem ${env:SystemDrive}\Users\ | where-object { $_.Name -like 'chocolate*' } | sort-object -Descending | select-object -first 1 | select-object Name
If($Chocolocal.count -gt 1){
    ForEach($account in $Chocolocal){
        $name = $account.name
        If((Test-Path "${env:SystemDrive}\Users\$name\AppData\Local\Postman\$ApplicationName.exe") -eq $True){ $Chocolocalname = $name }
    }
}
Else{ $Chocolocalname = $Chocolocal.name }
$SourcePath = "${env:SystemDrive}\Users\$Chocolocalname\AppData\Local\$ApplicationName"
#
#params
  $ConfigurationArguments = @{
    ApplicationName      = $ApplicationName
    SourcePath           = $SourcePath
    SourceExe            = "${env:SystemDrive}\$ApplicationName\$ApplicationName.exe"
    DestinationShortcut  = "${env:Public}\Desktop\$ApplicationName.lnk"
    DestinationStartMenu = "${env:AllUsersProfile}\Microsoft\Windows\Start Menu\Programs\$ApplicationName.lnk"
  }
#
#check for process
$Evaluations = Get-Process | Where-Object { $_.Name -like "$ApplicationName*" }
If ($Evaluations.Count -gt 0) {
  ForEach ($Evaluation in $Evaluations) {
    $StopProcess = $Evaluation.ProcessName 
    Stop-Process -Name $StopProcess -Force
  }
}
#User profile searches
$Users = Get-ChildItem "${env:SystemDrive}\users" -Exclude 'chocolatey', 'defaultuser0', 'public' | Select-Object FullName, Name
ForEach ($User in $Users) {
    $UserPath = $User.FullName
    $Username = $User.Name
    $PostmanUserPath = "$UserPath\AppData\Local\Postman\update.exe"
    #Evaluation
    Switch (Test-Path $PostmanUserPath) {
        $True {
            Remove-LocalPostman -PostmanUserPath $PostmanUserPath -Username $Username
            Write-Output "Postman remove it from $Username profile"
        }
        $False { }
    }
}
#Install actions
If ((Test-Path $SourcePath) -ne $False) {
    ConvertTo-LocalApplication @ConfigurationArguments
}
If ((Test-Path $SourcePath) -ne $True) { 
    Write-Output 'missing postman, installing pre-requisite app'
    & Choco feature enable -n allowGlobalConfirmation
    & Choco feature enable -n useRememberedArgumentsForUpgrades
    & Choco pin remove -n='postman'
    & Choco upgrade 'postman' -r --no-progress -y
    ConvertTo-LocalApplication @ConfigurationArguments
}
