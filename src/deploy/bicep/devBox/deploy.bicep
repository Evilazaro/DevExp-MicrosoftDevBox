param solutionName string

var devCenterName = format('{0}-devCenter', solutionName)

module identity '../identity/deploy.bicep' = {
  name: 'identity'
  params: {
    solutionName: solutionName
  }
}

output userIdentityId string = identity.outputs.identityPrincipalId
output userIdentityName string = identity.outputs.identityName

module computeGallery './computeGallery/deployComputeGallery.bicep' = {
  name: 'computeGallery'
  params: {
    solutionName: solutionName
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
    solutionName: solutionName
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
