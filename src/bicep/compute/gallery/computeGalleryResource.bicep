@description('Compute Gallery Name')
param name string

resource computeGallery 'Microsoft.Compute/galleries@2024-03-03' = {
  name: 'computeGallery-${name}-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  properties:{
    description: '${name} Compute Gallery'
  }
}
