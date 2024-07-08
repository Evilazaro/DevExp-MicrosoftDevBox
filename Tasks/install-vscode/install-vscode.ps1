Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 

Write-Host "Start to install VS Code for Windows"
winget install -e --id Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements --source winget --location "US"
Write-Host "End to install VS Code for Windows"