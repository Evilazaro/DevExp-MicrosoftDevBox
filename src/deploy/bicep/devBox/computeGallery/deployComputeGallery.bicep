param computeGalleryName string

resource computeGallery 'Microsoft.Compute/galleries@2023-07-03' = {
  name: computeGalleryName
  location: resourceGroup().location
  properties: {
    description: 'Compute gallery for Microsoft Dev Box Custom Images'
  }
}

output computeGalleryId string = computeGallery.id
output computeGalleryName string = computeGallery.name
