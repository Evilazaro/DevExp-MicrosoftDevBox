@description('Solution Name')
param solutionName string

@description('The name of the Dev Center')
var devCenterName = format('{0}DevCenter', solutionName)

@description('The name of the network resource group')
var networkResourceGroupName = format('{0}-Network-rg', solutionName)

var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'DevBox'
}

@description('Deploy the Managed Identity')
module identity '../identity/deploy.bicep' = {
  name: 'identity'
  params: {
    solutionName: solutionName
  }
}

@description('Deploy the Compute Gallery')
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


@description('The address prefix of the subnet')
var projects = [
  {
    name: 'eShop'
    networkConnectionName: 'eShop-Connection'
  }
  {
    name: 'contosoTraders'
    networkConnectionName: 'contosoTraders-Connection'
  }
]

@description('Deploy the Dev Center')
module devCenter 'devCenter/deployDevCenter.bicep' = {
  name: 'devCenter'
  params: {
    devCenterName: devCenterName
    identityName: identity.outputs.identityName
    computeGalleryName: computeGallery.outputs.computeGalleryName
    projects: projects
    networkResourceGroupName: networkResourceGroupName
    tags: tags
  }
  dependsOn: [
    computeGallery
  ]
}
