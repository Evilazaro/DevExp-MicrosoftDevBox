$URL="https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?_gl=1*h05men*_ga*NzE2MTUzMjUzLjE2OTMwMDE0NTA.*_ga_XJWPQMJYHQ*MTY5MzMyNTgzMC4yLjEuMTY5MzMyNTk3NC41OS4wLjA."
$PATH="C:\Temp\DockerDesktop.exe"

mkdir C:\Temp

Invoke-WebRequest -Uri $URL -OutFile $PATH
