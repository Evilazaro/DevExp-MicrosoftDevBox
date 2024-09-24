param devCenterName string
param devboxDefinitionName string
param networkConnectionName string 
param identityName string 
param customRoleName string 
param computeGalleryName string
param computeGalleryImageName string

module identity '../identity/deploy.bicep' = {
  name: 'identity'
  params: {
    identityName: identityName
    customRoleName: customRoleName
  }
}

output userIdentityId string = identity.outputs.identityPrincipalId
output userIdentityName string = identity.outputs.identityName

module computeGallery './computeGallery/deployComputeGallery.bicep' = {
  name: 'computeGallery'
  params: {
    computeGalleryName: computeGalleryName
  }
  dependsOn: [
    identity
  ]
}

output computeGalleryId string = computeGallery.outputs.computeGalleryId
output computeGalleryName string = computeGallery.outputs.computeGalleryName

module devCenter './devCenter/deployDevCenter.bicep' = {
  name: 'devCenter'
  params: {
    devCenterName: devCenterName
    devBoxDefinitionName: devboxDefinitionName
    location: resourceGroup().location
    networkConnectionName: networkConnectionName
    identityName: identity.outputs.identityName
    computeGalleryName: computeGalleryName
    computeGalleryImageName: computeGalleryImageName
  }
  dependsOn: [
    computeGallery
  ]
}
