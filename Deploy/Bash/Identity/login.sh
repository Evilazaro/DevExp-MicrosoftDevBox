#!/bin/bash

# This script helps users log in to their Azure account and set a specific subscription as active.

set -eou pipefail  # Safeguard: exit on error, unset variable usage, or pipe failure

# Constants
readonly PROGNAME=$(basename "$0")

# Functions

error_exit() {
    echo "${PROGNAME}: ${1:-"Unknown Error"}" >&2
    exit 1
}

usage() {
    echo "Usage: ${PROGNAME} [SUBSCRIPTION_ID]"
    exit 1
}

# Main script

clear  # Clear the terminal screen for better user experience

echo "Logging in to Azure"
echo "-------------------"

# Check if a subscription ID has been provided
[[ $# -eq 0 ]] && echo "Error: Subscription ID not provided!" && usage

readonly SUBSCRIPTION_ID="$1"

echo "Target Subscription: ${SUBSCRIPTION_ID}"
echo "-------------------"

# Prompt user to log in
echo "Please follow the on-screen instructions to log in."
if ! az login; then
    error_exit "Failed to log in to Azure."
fi

# Set the specified subscription as the active subscription
echo "Setting target subscription as active..."
if ! az account set --subscription "${SUBSCRIPTION_ID}"; then
    error_exit "Failed to set target subscription."
fi

echo "-------------------"
echo "Subscription set successfully!"
