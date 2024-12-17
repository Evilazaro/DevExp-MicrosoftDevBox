@description('Compute Gallery Name')
param name string

@description('Deploy Compute Gallery Resource')
resource computeGallery 'Microsoft.Compute/galleries@2024-03-03' = {
  name: 'computeGallery-${name}-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  properties:{
    description: '${name} Compute Gallery'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

@description('Gallery Identity Principal Id')
output galleryIdentityPrincipalId string = computeGallery.identity.principalId
