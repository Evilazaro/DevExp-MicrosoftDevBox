#!/bin/bash

appName="eShop"
displayName="ContosoDevEx GitHub Actions Enterprise App"

setup() {
    echo "Setting up deployment credentials..."
    ./Azure/generateDeploymentCredentials.sh "$appName" "$displayName"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to set up deployment credentials."
        return 1
    fi

    echo "Deployment credentials set up successfully."
}

clear
setup
