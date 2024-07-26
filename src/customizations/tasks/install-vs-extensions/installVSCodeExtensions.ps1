Set-ExecutionPolicy Bypass -Scope Process -Force; 
function InstallVSCodeExtensions {
    try {
        Write-Host "Installing VSCode extensions..."

        $extensions = @(
            "ms-vscode-remote.remote-wsl",
            "ms-vscode.PowerShell",
            "ms-vscode.vscode-node-azure-pack",
            "GitHub.copilot",
            "GitHub.vscode-pull-request-github",
            "GitHub.copilot-chat",
            "GitHub.remotehub",
            "GitHub.vscode-github-actions",
            "eamodio.gitlens-insiders",
            "ms-vscode.azure-repos",
            "ms-azure-devops.azure-pipelines",
            "ms-azuretools.vscode-docker",
            "ms-kubernetes-tools.vscode-kubernetes-tools",
            "ms-kubernetes-tools.vscode-aks-tools",
            "ms-azuretools.vscode-azurecontainerapps",
            "ms-azuretools.vscode-azurefunctions",
            "ms-azuretools.vscode-apimanagement"
        )

        foreach ($extension in $extensions) {
            code --install-extension $extension --force
        }

        Write-Host "VSCode extensions have been installed successfully."
    }
    catch {
        Write-Host "Failed to install VSCode extensions: $_" -Level "ERROR"
    }
}

InstallVSCodeExtensions