Set-ExecutionPolicy Bypass -Scope Process -Force;
choco install -y wsl-ubuntu-2204 --ignore-checksums --params "/AutomaticInstall:true";
choco install -y docker-desktop --ignore-checksums --ia '--quiet --accept-license';