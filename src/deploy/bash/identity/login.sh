#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
# Treat unset variables as an error
set -o nounset
# Prevent errors in a pipeline from being masked
set -o pipefail

# Function to display usage information
usage() {
    echo "Usage: $0 <subscriptionId>"
    exit 1
}

# Function to validate input parameters
validateParameters() {
    if [ "$#" -ne 1 ]; then
        echo "Error: Invalid number of arguments."
        usage
    fi
}

# Function to set the Azure subscription
setAzureSubscription() {
    local subscriptionId="$1"
    echo "Attempting to set subscription to ${subscriptionId}..."

    az login --use-device-code
    
    if az account set --subscription "${subscriptionId}"; then
        echo "Successfully set Azure subscription to ${subscriptionId}."
    else
        echo "Error: Failed to set Azure subscription to ${subscriptionId}. Please check if the subscription ID is valid and you have access to it."
        exit 1
    fi
}

# Main script execution
main() {
    validateParameters "$@"
    setAzureSubscription "$@"
}

# Execute the main function with all script arguments
main "$@"