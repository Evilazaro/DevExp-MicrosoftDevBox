Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 

Write-Host "Start to install Postman for Windows"
winget install Postman.Postman --silent --accept-package-agreements --accept-source-agreements
Write-Host "End to install Postman for Windows"

#net localgroup docker-users "NT AUTHORITY\Authenticated Users" /ADD