#!/bin/bash

# Ensure the script stops on the first error
set -e

# Ensure a command line argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <subscriptionId>"
    exit 1
fi

# Assigning argument to a variable for better readability
subscriptionId=$1

# Step 1: Logging in to Azure
echo "Attempting to log in to Azure..."
az login
echo "Successfully logged in to Azure."

# Step 2: Setting the Azure subscription
echo "Attempting to set subscription to ${subscriptionId}..."
# Check if the subscription exists and is valid
if az account set --subscription "${subscriptionId}"; then
    echo "Successfully set Azure subscription to ${subscriptionId}."
else
    echo "Failed to set Azure subscription to ${subscriptionId}. Please check if the subscription ID is valid and you have access to it."
    exit 1
fi

# Additional comments for future steps or improvements can be added below this line.
