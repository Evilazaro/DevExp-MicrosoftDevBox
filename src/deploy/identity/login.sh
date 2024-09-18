#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set the subscription ID
readonly subscriptionId="$1"

# Function to display usage information
usage() {
    echo "Usage: $0 <subscriptionId>"
    exit 1
}

# Function to log into Azure
logIntoAzure() {
    echo "Attempting to log into Azure..."
    if az login --use-device-code; then
        echo "Successfully logged into Azure."
        setAzureSubscription
    else
        echo "Error: Failed to log into Azure."
        exit 1
    fi
}

# Function to set the Azure subscription
setAzureSubscription() {
    echo "Attempting to set subscription to ${subscriptionId}..."
    
    if az account set --subscription "${subscriptionId}"; then
        echo "Successfully set Azure subscription to ${subscriptionId}."
    else
        echo "Error: Failed to set Azure subscription to ${subscriptionId}. Please check if the subscription ID is valid and you have access to it."
        exit 1
    fi
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    usage
fi

# Log into Azure and set the subscription
logIntoAzure