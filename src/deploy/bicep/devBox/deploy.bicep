param solutionName string

var devCenterName = format('{0}DevCenter', solutionName)
var networkResourceGroupName = format('{0}-Network-rg', solutionName)
var virtualNetworkConnectionName = format('{0}-networkConnection', solutionName)
var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'DevBox'
}

module identity '../identity/deploy.bicep' = {
  name: 'identity'
  params: {
    solutionName: solutionName
  }
}

module computeGallery './computeGallery/deployComputeGallery.bicep' = {
  name: 'computeGallery'
  params: {
    solutionName: solutionName
    tags: tags
  }
  dependsOn: [
    identity
  ]
}

module devCenter 'devCenter/deployDevCenter.bicep' = {
  name: 'devCenter'
  params: {
    devCenterName: devCenterName
    identityName: identity.outputs.identityName
    computeGalleryName: computeGallery.outputs.computeGalleryName
    netWorkConnectionName: virtualNetworkConnectionName
    networkResourceGroupName: networkResourceGroupName
    tags: tags
  }
  dependsOn: [
    computeGallery
  ]
}
