#!/bin/bash

# This script helps users log in to their Azure account and set a specific subscription as active.

# Functions

function error_exit() {
    echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    exit 1
}

# Constants
PROGNAME=$(basename $0)

# Begin main script

# Clear the terminal screen for better user experience.
clear

# Print a header to indicate the start of the Azure login process.
echo "Logging in to Azure"
echo "-------------------"

# Check if a subscription ID has been provided. If not, exit the script with a usage message.
if [ -z "$1" ]; then
    echo "Error: Subscription ID not provided!"
    echo "Usage: ${PROGNAME} [SUBSCRIPTION_ID]"
    exit 1
fi

SUBSCRIPTION_ID=$1

# Display the subscription ID the user intends to set as active.
echo "Target Subscription: ${SUBSCRIPTION_ID}"
echo "-------------------"

# Prompt user to log in to their Azure account using the Azure CLI.
# They'll be redirected to a browser-based authentication process.
echo "Please follow the on-screen instructions to log in."
if ! az login; then
    error_exit "Failed to log in to Azure."
fi

# After successful login, set the specified subscription as the active subscription.
echo "Setting target subscription as active..."
if ! az account set --subscription ${SUBSCRIPTION_ID}; then
    error_exit "Failed to set target subscription."
fi

echo "-------------------"
echo "Subscription set successfully!"
