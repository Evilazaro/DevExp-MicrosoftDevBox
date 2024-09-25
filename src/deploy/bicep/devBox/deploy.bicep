param devCenterName string
param networkConnectionName string 
param identityName string 
param customRoleName string 
param computeGalleryName string
param networkResourceGroupName string

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
    location: resourceGroup().location
    networkConnectionName: networkConnectionName
    identityName: identity.outputs.identityName
    computeGalleryName: computeGalleryName
    networkResourceGroupName: networkResourceGroupName
  }
  dependsOn: [
    computeGallery
  ]
}

output devCenterId string = devCenter.outputs.devCenterId
output devCenterName string = devCenter.outputs.devCenterName
output devCenterIdentityId string = devCenter.outputs.devCenterIdentityId
output devCenterName_quickstart_devbox_tasks_id string = devCenter.outputs.devCenterName_quickstart_devbox_tasks_id
output devCenterName_quickstart_devbox_tasks_name string = devCenter.outputs.devCenterName_quickstart_devbox_tasks_name
output devCenterName_networkConnection_id string = devCenter.outputs.devCenterName_networkConnection_id
output devCenterName_networkConnection_name string = devCenter.outputs.devCenterName_networkConnection_name
output devCenterName_computeGalleryImage_id string = devCenter.outputs.devCenterName_computeGalleryImage_id
output devCenterName_computeGalleryImage_name string = devCenter.outputs.devCenterName_computeGalleryImage_name

