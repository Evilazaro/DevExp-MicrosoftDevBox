#!/bin/bash

# Ensure the script stops on the first error
set -e

function usage() {
    echo "Usage: $0 <subscriptionId>"
    exit 1
}

function logIntoAzure() {
    echo "Attempting to log into Azure..."
    az login --use-device-code
    echo "Successfully logged into Azure."
}

function setAzureSubscription() {
    local subscriptionId="$1"
    echo "Attempting to set subscription to ${subscriptionId}..."
    
    if az account set --subscription "${subscriptionId}"; then
        echo "Successfully set Azure subscription to ${subscriptionId}."
    else
        echo "Failed to set Azure subscription to ${subscriptionId}. Please check if the subscription ID is valid and you have access to it."
        exit 1
    fi
}

# Ensure a command line argument is provided
if [ "$#" -ne 1 ]; then
    usage
fi

subscriptionId="$1"

logIntoAzure
setAzureSubscription "${subscriptionId}"

# Additional comments for future steps or improvements can be added below this line.