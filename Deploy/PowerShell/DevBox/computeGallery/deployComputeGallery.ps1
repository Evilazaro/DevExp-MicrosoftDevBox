# Check if the correct number of arguments are passed, if not, exit with an error message
if ($args.Length -ne 3) {
    Write-Host "Usage: .\<scriptname>.ps1 <ComputeGalleryName> <Location> <GalleryResourceGroupName>"
    exit 1
}

# Assigning input arguments to descriptive variable names for better clarity and readability
$computeGalleryName = $args[0]
$location = $args[1]
$galleryResourceGroupName = $args[2]

# Informing the user about the start of resource creation
Write-Host "Initializing the creation of a Shared Image Gallery named '$computeGalleryName' in resource group '$galleryResourceGroupName' located in '$location'."

# Execute the Azure command to create the resource, with tags for better resource categorization and management
# Echoing the command before running it for better user awareness
Write-Host "Executing Azure CLI command to create the Shared Image Gallery..."
az sig create `
    --gallery-name $computeGalleryName `
    --resource-group $galleryResourceGroupName `
    --location $location `
    --tags  "Division=Contoso-Platform" `
            "Environment=Prod" `
            "Offer=Contoso-DevWorkstation-Service" `
            "Team=Engineering" `
            "Solution=eShop" `
            "BusinessUnit=e-Commerce"

# Confirming the successful creation of the resource
Write-Host "Shared Image Gallery '$computeGalleryName' successfully created in resource group '$galleryResourceGroupName' located in '$location'."
