#!/bin/bash

appName="GitHub Actions Enterprise App10"

# Function to create a new Azure AD application and service principal
registerNewAppAzureAd() {
    local appName="$1"

    # Check if required parameter is provided
    if [[ -z "$appName" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: registerNewAppAzureAd <appName>"
        return 1
    fi

    echo "Creating new Azure AD application with display name: $appName"

    # Create the Azure AD application and capture the appId
    local appId
    appId=$(az ad app create --display-name "$appName" --query appId -o tsv)
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create Azure AD application."
        return 1
    fi

    echo "Azure AD application created successfully with appId: $appId"

    # Create the service principal for the application
    createServicePrincipal "$appId"
    
}

# Function to create a service principal for a given Azure AD application
createServicePrincipal() {
    local appId="$1"

    # Check if required parameter is provided
    if [[ -z "$appId" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: createServicePrincipal <appId>"
        return 1
    fi

    echo "Creating service principal for appId: $appId"

    # Create the service principal and capture the result
    local spAppId
    spAppId=$(az ad sp create --id "$appId" --query appId -o tsv)
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create service principal for appId: $appId"
        return 1
    fi

    servicePrincipalId=$(az ad sp show --id "$spAppId" --query id -o tsv)

    echo "Service principal created successfully with appId: $spAppId and servicePrincipalId: $servicePrincipalId"
}

# Function to assign roles to a service principal
assignRolesServicePrincipal() {
    local appId="$1"

    # Check if required parameter is provided
    if [[ -z "$appId" ]]; then
        echo "Error: Missing required parameter."
        echo "Usage: assignRolesServicePrincipal <appId>"
        return 1
    fi

    echo "Assigning roles to service principal with appId: $appId"

    # Define roles to be assigned
    local roles=("Contributor" "Owner")
    local subscriptionId
    subscriptionId=$(az account show --query id --output tsv)
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to retrieve subscription ID."
        return 1
    fi

    # Loop through each role and assign it to the service principal
    for role in "${roles[@]}"; do
        local roleDefinitionId
        roleDefinitionId=$(az role definition list --name "$role" --query "[0].name" -o tsv)
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to retrieve role definition ID for role: $role"
            return 1
        fi

        assignRole "$appId" "$roleDefinitionId" "$subscriptionId"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to assign role: $role to appId: $appId"
            return 1
        fi
    done

    echo "Roles assigned successfully to service principal with appId: $appId"
}

# Function to assign a specific role to a service principal
assignRole() {
    local appId="$1"
    local roleDefinitionId="$2"
    local subscriptionId="$3"

    # Check if required parameters are provided
    if [[ -z "$appId" || -z "$roleDefinitionId" || -z "$subscriptionId" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: assignRole <appId> <roleDefinitionId> <subscriptionId>"
        return 1
    fi

    echo "Assigning role with roleDefinitionId: $roleDefinitionId to appId: $appId"

    # Assign the role to the service principal
    az role assignment create --assignee "$appId" --role "$roleDefinitionId" --scope "/subscriptions/$subscriptionId"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to assign role with roleDefinitionId: $roleDefinitionId to appId: $appId"
        return 1
    fi

    echo "Role with roleDefinitionId: $roleDefinitionId assigned successfully to appId: $appId"
}

# Example usage
# assignRolesServicePrincipal "your-app-id"

createClientSecretApp(){
    local appId="$1"
    az ad app credential reset --id "$appId" --credential-description "GitHub Actions Enterprise App Secret" --query password -o tsv
}

registerNewAppAzureAd "$appName"