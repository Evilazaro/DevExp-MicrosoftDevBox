Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 

$Choco = "$Env:ProgramData/chocolatey/choco.exe"

if(-not (Test-Path "$Choco")){
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Write-Host "Start to install VS Code for Windows"
choco install vscode -y --no-progress --ignore-checksums
Write-Host "End to install VS Code for Windows"