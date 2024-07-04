Param(
    [string]$MarketplaceItemName
)

# Check if the Visual Studio Code command-line utility is available
if (Get-Command code -ErrorAction SilentlyContinue) {
    # Install the extension
    code --install-extension $MarketplaceItemName
    Write-Host "Extension '$MarketplaceItemName' has been installed."
}
else {
    Write-Error "Visual Studio Code command-line utility (code) is not available in PATH."
}
