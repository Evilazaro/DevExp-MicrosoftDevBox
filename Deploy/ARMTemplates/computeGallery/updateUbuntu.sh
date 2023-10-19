#!/bin/bash

set -euo pipefail

# Update the Ubuntu package list and upgrade the packages
updateUbuntu() {
    sudo apt-get update && sudo apt-get upgrade -y
}

main() {
    updateUbuntu
}

# Call the main function to initiate the script
main
