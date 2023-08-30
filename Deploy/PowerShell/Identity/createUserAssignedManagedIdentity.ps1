<#
.SYNOPSIS
Script to assign a role to a User-Assigned Managed Identity in Azure
#>

# Constants
$ROLE = "Owner"

# Print usage message
function Usage {
    Write-Host "Usage: $($MyInvocation.MyCommand) -ResourceGroup <Resource Group> -SubscriptionID <Subscription ID> -IdentityID <Identity ID>"
}

# Check the number of arguments provided to the script
function CheckArgs {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroup,
        
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionID,
        
        [Parameter(Mandatory = $true)]
        [string]$IdentityID
    )

    # PowerShell automatically checks mandatory parameters. No need to check manually.
}

# Print a header for better output readability
function PrintHeader {
    param(
        [string]$Header
    )

    Write-Host ("-" * 60)
    Write-Host $Header
    Write-Host ("-" * 60)
}

# Assign a role to the identity for a specific subscription
function AssignRole {
    param(
        [string]$Identity,
        [string]$Role,
        [string]$Subscription
    )

    Write-Host "Assigning '$Role' role to the identity..."
    if(az role assignment create --assignee $Identity --role $Role --scope /subscriptions/$Subscription) {
        Write-Host "'$Role' role successfully assigned to the identity in the subscription."
    } else {
        Write-Host "Error: Failed to assign '$Role' role to the identity."
        exit 2
    }
}

# Main script execution

# Extract parameters from command-line arguments
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory=$true)]
    [string]$SubscriptionID,

    [Parameter(Mandatory=$true)]
    [string]$IdentityID
)

CheckArgs -ResourceGroup $ResourceGroup -SubscriptionID $SubscriptionID -IdentityID $IdentityID

PrintHeader "Creating a User-Assigned Managed Identity & Granting Permissions"

# Displaying the input details for confirmation
Write-Host "Details Provided:"
Write-Host "Resource Group: $ResourceGroup"
Write-Host "Subscription ID: $SubscriptionID"
Write-Host "Identity ID: $IdentityID"
Write-Host ("-" * 60)

AssignRole -Identity $IdentityID -Role $ROLE -Subscription $SubscriptionID
