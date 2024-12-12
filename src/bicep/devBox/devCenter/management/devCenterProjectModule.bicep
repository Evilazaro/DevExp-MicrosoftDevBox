@description('Dev Center Name')
param devCenterName string

@description('Projects')
var projects = [
  {
    name: 'eShop'
    tags: {
      division: 'PlatformEngineeringTeam-DevEx'
      enrironment: 'Production'
      offering: 'DevBox-as-a-Service'
      solution: 'DevBox'
      landingZone: 'eShop'
    }
  }
  {
    name: 'Contoso-Traders'
    tags: {
      division: 'PlatformEngineeringTeam-DevEx'
      enrironment: 'Production'
      offering: 'DevBox-as-a-Service'
      solution: 'Contoso Traders'
      landingZone: 'DevBox'
    }
  }
  {
    name: 'DevBox'
    tags: {
      division: 'PlatformEngineeringTeam-DevEx'
      enrironment: 'Production'
      offering: 'DevBox-as-a-Service'
      solution: 'DevBox'
      landingZone: 'DevBox'
    }
  }
]

module deployDevCenterProject 'devCenterProjectResource.bicep' = [
  for project in projects: {
    name: 'Project-${project.name}'
    params: {
      devCenterName: devCenterName
      name: project.name
      tags: project.tags
    }
  }
]
