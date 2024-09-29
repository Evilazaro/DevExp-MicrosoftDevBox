param devCenterName string
param vNetName string 
param identityName string 
param customRoleName string 
param computeGalleryName string
param networkResourceGroupName string
param logAnalyticsWorkspaceName string
param managementResourceGroupName string

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
  name: computeGalleryName
  params: {
    computeGalleryName: computeGalleryName
  }
  dependsOn: [
    identity
  ]
}

output computeGalleryId string = computeGallery.outputs.computeGalleryId
output computeGalleryName string = computeGallery.outputs.computeGalleryName

module devCenter 'devCenter/deployDevCenter.bicep' = {
  name: 'devCenter'
  params: {
    devCenterName: devCenterName
    location: resourceGroup().location
    vNetName: vNetName
    identityName: identity.outputs.identityName
    computeGalleryName: computeGalleryName
    networkResourceGroupName: networkResourceGroupName
    logAnalyticsWorkspaceName:logAnalyticsWorkspaceName
    managementResourceGroupName: managementResourceGroupName
  }
  dependsOn: [
    computeGallery
  ]
}


output devCenterId string = devCenter.outputs.devCenterId
output devCenterName string = devCenter.outputs.devCenterName
output devCenterIdentityId string = devCenter.outputs.devCenterIdentityId
output devCenterDiagnosticSettingsId string = devCenter.outputs.devCenterDiagnosticSettingsId
output devCenterDiagnosticSettingsName string = devCenter.outputs.devCenterDiagnosticSettingsName
output devCenterDiagnosticSettingsWorkspaceId string = devCenter.outputs.devCenterDiagnosticSettingsWorkspaceId
