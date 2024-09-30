param solutionName string

var devCenterName = format('{0}DevCenter', solutionName)
var logAnalyticsWorkspaceName = format('{0}-logAnalytics', solutionName)
var managementResourceGroupName = format('{0}-Management-rg', solutionName)
var networkResourceGroupName = format('{0}-Network-rg', solutionName)
var vnetName = format('{0}-vnet', solutionName)
var netWorkConnectionName = format('{0}-netWorkConnection', vnetName)

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
    devCenterName: devCenterName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    managementResourceGroupName: managementResourceGroupName
    identityName: identity.outputs.identityName
    computeGalleryName: computeGallery.outputs.computeGalleryName
    netWorkConnectionName: netWorkConnectionName
    networkResourceGroupName: networkResourceGroupName
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
