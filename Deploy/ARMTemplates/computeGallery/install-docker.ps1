Set-ExecutionPolicy Bypass -Scope Process -Force;
choco install wsl-ubuntu-2204 --params "/AutomaticInstall:true";
choco install -y docker-desktop --ignore-checksums --ia '--quiet --accept-license';