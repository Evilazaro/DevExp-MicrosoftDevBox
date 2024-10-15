@description('Solution Name')
param solutionName string

@description('Teams and Projects for the Dev Center')
var projects = [
  {
    name: 'eShop'
    description: 'eShop Reference Application - AdventureWorks'
    networkConnectionName: 'eShop-Connection'
    catalog: {
      name: 'eShop'
      type: 'gitHub'
      uri: 'https://github.com/Evilazaro/eShop.git'
      branch: 'main'
      path: '/.devcenter/customizations/tasks'
    }
  }
  {
    name: 'contosoTraders'
    description: 'Contoso Traders Reference Application - Contoso'
    networkConnectionName: 'contosoTraders-Connection'
    catalog: {
      name: 'contosoTraders'
      type: 'gitHub'
      uri: 'https://github.com/Evilazaro/ContosoTraders.git'
      branch: 'main'
      path: '/customizations/tasks'
    }
  }
]

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

@description('Deploy the Dev Center')
module devCenter 'devCenter/deployDevCenter.bicep' = {
  name: 'devCenter'
  params: {
    name: devCenterName
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
