#!/bin/bash

# This script assists users in logging into their Azure account and sets a specified subscription as active.

# Exit on error, unset variable usage, or pipe failure
set -eou pipefail

# Constants
readonly PROGNAME=$(basename "$0")

# Functions

# Display an error message and exit the script
error_exit() {
    echo "${PROGNAME}: ${1:-"Unknown Error"}" >&2
    exit 1
}

# Display the script usage instructions
usage() {
    echo "Usage: ${PROGNAME} [SUBSCRIPTION_ID]"
    exit 1
}

# Main script execution

# Clear the terminal screen for a cleaner user experience
clear

echo "Logging in to Azure"
echo "-------------------"

# Ensure a subscription ID is provided; if not, display an error and usage message
if [[ $# -eq 0 ]]; then
    echo "Error: Subscription ID not provided!"
    usage
fi

readonly SUBSCRIPTION_ID="$1"

echo "Target Subscription: ${SUBSCRIPTION_ID}"
echo "-------------------"

# Prompt the user to log in and follow on-screen instructions
echo "Please follow the on-screen instructions to log in."
if ! az login; then
    error_exit "Failed to log in to Azure."
fi

# Attempt to set the provided subscription ID as the active subscription
echo "Setting target subscription as active..."
if ! az account set --subscription "${SUBSCRIPTION_ID}"; then
    error_exit "Failed to set target subscription."
fi

echo "-------------------"
echo "Subscription set successfully!"
