#!/bin/bash

# This script is designed to help a user log in to their Azure account and set a specific subscription as active.

# Clear the terminal screen for better readability.
clear

# Print a header to indicate the start of the Azure login process.
echo "Logging in to Azure"
echo "-------------------"

# Check if a subscription ID has been provided. If not, exit the script with an error message.
if [ -z "$1" ]; then
    echo "Error: Subscription ID not provided!"
    echo "Usage: $0 [SUBSCRIPTION_ID]"
    exit 1
fi

# Display the subscription ID the user intends to set as active.
echo "Target Subscription: $1"
echo "-------------------"

# Use the Azure CLI to prompt the user to log in to their Azure account.
# The user will be redirected to a browser-based authentication process.
echo "Please follow the on-screen instructions to log in."
az login

# After successful login, set the specified subscription (provided as the first argument) as the active subscription.
echo "Setting target subscription as active..."
az account set --subscription $1
echo "-------------------"
echo "Subscription set successfully!"
