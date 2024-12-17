@description('Workload Name')
param workloadName string 

@description('Workload Name')
param devCenterName string

@description('Role Definition Ids')
param roleDefinitionIds array

@description('DevCenter Resource')
resource devCenterResource 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Deploy Compute Gallery Resource')
module computeGallery 'computeGalleryResource.bicep' = {
  name: 'computeGallery'
  scope: resourceGroup()
  params: {
    name: workloadName
  }
  dependsOn: [
    devCenterResource
  ]
}

@description('Role Assignment Resource')
module roleAssignmentGallery '../../identity/roleAssignmentResource.bicep' = {
  name: 'roleAssignmentConputeGallery'
  scope: subscription()
  params: {
    principalId: computeGallery.outputs.galleryIdentityPrincipalId
    roleDefinitionIds: roleDefinitionIds
  }
}

@description('Deploy Compute Gallery Dev Center Resource')
resource computeGalleryDevCenter 'Microsoft.DevCenter/devcenters/galleries@2024-10-01-preview' = {
  name: devCenterName
  parent: devCenterResource
}
