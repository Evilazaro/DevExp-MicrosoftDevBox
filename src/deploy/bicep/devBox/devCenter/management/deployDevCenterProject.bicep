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
    name: 'Contoso Traders'
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

module deployDevCenterProject 'devCenterProject.bicep' = [
  for project in projects: {
    name: 'Project-${project}'
    params: {
      devCenterName: devCenterName
      name: project.name
      tags: project.tags
    }
  }
]

@description('Dev Center Project Resource IDs')
output devCenterProjectIds array = [for (project,i) in projects: deployDevCenterProject[i].outputs.devCenterProjectId]

@description('Dev Center Project Resource Names')
output devCenterProjectNames array = [for (project,i) in projects: deployDevCenterProject[i].outputs.devCenterProjectName]
