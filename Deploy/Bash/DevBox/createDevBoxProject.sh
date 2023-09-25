
#!/bin/bash

location="$1"
subscriptionId="$2"
resourceGroupName="$3"
devCenterName="$4"

az devcenter admin project create \
    --location "$location" \
    --description "Sample .NET Core reference application, powered by Microsoft" \
    --dev-center-id "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName" \
    --name "eShop" \
    --resource-group "$resourceGroupName" \
    --max-dev-boxes-per-user "10" \
    --tags  "division=Contoso-Platform" \
            "Environment=Prod" \
            "offer=Contoso-DevWorkstation-Service" \
            "Team=Engineering" \
            "division=Contoso-Platform" \
            "solution=eShop" \
            "businessUnit=e-Commerce"