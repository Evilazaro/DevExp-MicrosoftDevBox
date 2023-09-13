#!/usr/bin/env bash

# Validate the number of command line arguments
if [[ $# -lt 6 ]]; then
  echo "Usage: $0 <location> <devbox_definition_name> <network_connection_name> <pool_name> <project_name> <resource_group>"
  exit 1
fi

# Assign command line arguments to variables with meaningful names
location="$1"
devbox_definition_name="$2"
network_connection_name="$3"
pool_name="$4"
project_name="$5"
resource_group="$6"

# Echo the values to be used in creating the pool
echo "Using the following values to create the pool:"
echo "Location: $location"
echo "DevBox Definition Name: $devbox_definition_name"
echo "Network Connection Name: $network_connection_name"
echo "Pool Name: $pool_name"
echo "Project Name: $project_name"
echo "Resource Group: $resource_group"

# Execute the az devcenter admin pool create command with the defined variables
# Also, removing duplicate tag keys and streamlining the tag assignment section
echo "Creating pool..."
az devcenter admin pool create \
    --location "$location" \
    --devbox-definition-name "$devbox_definition_name" \
    --network-connection-name "$network_connection_name" \
    --pool-name "$pool_name" \
    --project-name "$project_name" \
    --resource-group "$resource_group" \
    --local-administrator "Enabled" \
    --tags  "Division=Contoso-Platform" \
            "Environment=Prod" \
            "Offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "Solution=eShop" \
            "BusinessUnit=e-Commerce"

# Echo a completion message
echo "Pool creation completed."
