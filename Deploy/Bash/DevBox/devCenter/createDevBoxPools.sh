#!/bin/bash


location="$1"
devbox_definition_name="$2"
network_connection_name="$3"
pool_name="$4"
project_name="$5"
resource_group="$6"

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


