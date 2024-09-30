param devCenterName string
param computeGalleryName string

resource deployDevCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}

@description('Create DevCenter Compute Gallery')
resource devCenterComputeGallery 'Microsoft.DevCenter/devcenters/galleries@2024-02-01' = {
  parent: deployDevCenter
  name: computeGalleryName
  properties: {
    galleryResourceId: resourceId('Microsoft.Compute/galleries', computeGalleryName)
  }
}

output devCenterName_computeGalleryImage_id string = devCenterComputeGallery.id
output devCenterName_computeGalleryImage_name string = devCenterComputeGallery.name
