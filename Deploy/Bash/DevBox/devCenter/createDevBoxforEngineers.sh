#!/bin/bash

# Assign command line arguments to variables with meaningful names
poolName="$1"
devBoxName="$2"
devCenterName="$3"
projectName="$4"

currentUserName=$(az account show --query user.name -o tsv)
currentAzureLoggedUser=$(az ad user show --id "$currentUserName" --query id -o tsv)

az devcenter dev dev-box create \
    --pool-name "$poolName" \
    --name "$devBoxName" \
    --dev-center-name "$devCenterName" \
    --project-name "$projectName" \
    --user-id "$currentAzureLoggedUser" \
    --local-administrator Enabled 

