#!/bin/bash

deleteCustomRoleAndAssignments() {
    local roleName="$1"
    echo "Deleting role assignments for the '$roleName' role..."
    local roleId=$(az role definition list --name "$roleName" --query "[].name" --output tsv)

    if [[ -z "$roleId" ]]; then
        echo "Role ID for '$roleName' not found. Skipping role assignment deletion."
        return
    fi

    local assignments=$(az role assignment list --role "$roleId" --query "[].id" --output tsv)
    if [[ -z "$assignments" ]]; then
        echo "No assignments found for role '$roleName'."
    else
        for assignment in $assignments; do
            echo "Deleting role assignment: $assignment"
            az role assignment delete --ids "$assignment"
            echo "Role assignment $assignment deleted."
        done
    fi

    echo "Deleting the '$roleName' role..."
    az role definition delete --name "$roleName"

    while [ "$(az role definition list --name "$roleName" --query "[].roleName" -o tsv)" == "$roleName" ]; do
        echo "Waiting for the role to be deleted..."
        sleep 10
    done
    echo "'$roleName' role successfully deleted."
}

# Example usage
deleteCustomRoleAndAssignments "$customRoleName"