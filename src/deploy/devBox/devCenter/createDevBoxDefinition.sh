#!/bin/bash

# Check if all required arguments are provided
if [[ $# -lt 7 ]]; then
    echo "Usage: $0 <subscriptionId> <location> <devBoxResourceGroupName> <devCenterName> <galleryName> <imageName> <networkConnectionName>"
    exit 1
fi

# Assign input arguments to camelCase variables
subscriptionId="$1"
location="$2"
devBoxResourceGroupName="$3"
devCenterName="$4"
galleryName="$5"
imageName="$6"
networkConnectionName="$7"
buildImage="$8"

echo "Updating DevCEnter..."

#!/bin/bash

# List of DevOps best practices adjectives
adjectives=("Automated" "Continuous" "Integrated" "Scalable" "Efficient" "Resilient" "Reliable" "Secure" "Optimized" "Collaborative"
            "Agile" "Adaptive" "Dynamic" "Flexible" "Innovative" "Proactive" "Robust" "Streamlined" "Unified" "Versatile"
            "Responsive" "Compliant" "Consistent" "Effective" "Expandable" "Maintainable" "Portable" "Scalable" "Automated"
            "Efficient" "Interoperable" "Modular" "Robust" "Streamlined" "Sustainable" "Unified" "Versatile" "Resilient" 
            "Optimized" "Collaborative" "Agile" "Adaptive" "Dynamic" "Flexible" "Innovative" "Proactive" "Reliable")

# List of software development terms
terms=("Developer" "Architect" "Engineer" "Coder" "Programmer" "Hacker" "Debugger" "Designer" "Analyst" "Tester"
       "SysAdmin" "DevOps" "ScrumMaster" "ProductOwner" "TechLead" "TeamLead" "Backend" "Frontend" "FullStack" "Database"
       "Administrator" "CloudSpecialist" "SRE" "NetworkEngineer" "SecurityAnalyst" "QAEngineer" "DataScientist" "AIEngineer" 
       "MachineLearning" "Consultant" "AutomationSpecialist" "BuildMaster" "ReleaseManager" "ProjectManager" "BusinessAnalyst"
       "SupportEngineer" "SystemArchitect" "IntegrationSpecialist" "SolutionArchitect" "TechSupport" "InfrastructureEngineer"
       "PlatformEngineer" "ServiceManager" "ITManager" "SoftwareConsultant" "CloudEngineer" "ITConsultant" "OperationsManager"
       "DevSecOps")

# Function to generate a random name
generate_random_name() {
  local random_adjective=${adjectives[$RANDOM % ${#adjectives[@]}]}
  local random_term=${terms[$RANDOM % ${#terms[@]}]}
  local random_number=$((RANDOM % 1000))
  echo "${random_adjective}${random_term}${random_number}"
}

# Function to get the content before the underscore
get_before_hyphen() {
  local input_string="$1"
  # Use parameter expansion to extract the content before the underscore
  local result="${input_string%%-*}"
  echo "$result"
}

# Function to create development pools and boxes
createDevPoolsAndDevBoxes() {
    local location="$1"
    local devBoxDefinitionName="$2"
    local networkConnectionName="$3"
    local poolName="$4"
    local devBoxResourceGroupName="$5"
    local devBoxName="$6"
    local devCenterName="$7"

    declare -A projects=(
        ["eShop"]="eShop"
    )

    for projectName in "${!projects[@]}"; do
        # Creating DevBox Pools
        echo "Creating DevBox Pools for $projectName..."
        ./devBox/devCenter/createDevBoxPools.sh "$location" "$devBoxDefinitionName" "$networkConnectionName" "$poolName" "$projectName" "$devBoxResourceGroupName"
        echo "DevBox Pools for $projectName created successfully."
    done
}

# Inform the user about the initialization step
echo "Initializing script with:
subscriptionId: $subscriptionId
location: $location
devBoxResourceGroupName: $devBoxResourceGroupName
devCenterName: $devCenterName
galleryName: $galleryName
imageName: $imageName."

# Construct necessary variables
if ("$buildImage" == "true"); then
    imageReferenceId="/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/${galleryName}/images/${imageName}/versions/1.0.0"   
else
    imageReferenceId="/subscriptions/$subscriptionId/resourceGroups/$devBoxResourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/Default/images/${imageName}"
fi

devBoxDefinitionName="$(generate_random_name)-def"
poolName="$(get_before_hyphen $devBoxDefinitionName)-pool"
devBoxName="$(get_before_hyphen $devBoxDefinitionName)-devbox"

# Display constructed variables
echo "Constructed variables:
imageReferenceId: $imageReferenceId
devBoxDefinitionName: $devBoxDefinitionName
networkConnectionName: $networkConnectionName
poolName: $poolName
devBoxName: $devBoxName
imageName: $imageName"

# Create a DevBox definition
echo "Creating DevBox definition..."
az devcenter admin devbox-definition create --location "$location" \
    --image-reference id="$imageReferenceId" \
    --os-storage-type "ssd_256gb" \
    --sku name="general_i_8c32gb256ssd_v2" \
    --name "$devBoxDefinitionName" \
    --dev-center-name "$devCenterName" \
    --resource-group "$devBoxResourceGroupName"

echo "DevBox definition created successfully."

# Invoke the function to create development pools and boxes
createDevPoolsAndDevBoxes "$location" "$devBoxDefinitionName" "$networkConnectionName" "$poolName" "$devBoxResourceGroupName" "$devBoxName" "$devCenterName"
