#!/bin/bash

# -----------------------------------------------------------------------------
# Script to assign a role to a User-Assigned Managed Identity in Azure
# -----------------------------------------------------------------------------

# Constants
ROLE="Owner"

# Print usage message
usage() {
    echo "Usage: $0 <Resource Group> <Subscription ID> <Identity ID>"
}

# Check the number of arguments provided to the script
check_args() {
    if [ "$#" -ne 3 ]; then
        echo "Error: You must provide exactly 3 arguments."
        usage
        exit 1
    fi
}

# Print a header for better output readability
print_header() {
    local header=$1
    echo "-------------------------------------------------------------"
    echo "$header"
    echo "-------------------------------------------------------------"
}

# Assign a role to the identity for a specific subscription
assign_role() {
    local identity=$1
    local role=$2
    local subscription=$3

    echo "Assigning '$role' role to the identity..."
    if az role assignment create --assignee "$identity" --role "$role" --scope /subscriptions/"$subscription"; then
        echo "'$role' role successfully assigned to the identity in the subscription."
    else
        echo "Error: Failed to assign '$role' role to the identity."
        exit 2
    fi
}

# Main script execution
check_args "$@"

print_header "Creating a User-Assigned Managed Identity & Granting Permissions"

# Extracting and displaying provided arguments
imageResourceGroup="$1"
subscriptionID="$2"
identityId="$3"

# Displaying the input details for confirmation
echo "Details Provided:"
echo "Resource Group: $imageResourceGroup"
echo "Subscription ID: $subscriptionID"
echo "Identity ID: $identityId"
echo "-------------------------------------------------------------"

assign_role "$identityId" "$ROLE" "$subscriptionID"
