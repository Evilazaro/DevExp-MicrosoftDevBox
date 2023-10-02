Set-ExecutionPolicy Bypass -Scope Process -Force;
choco install -y --ignore-checksums wsl-ubuntu-2204;
choco install -y --ignore-checksums docker-desktop  --ia '--quiet --accept-license';