@description('Dev Center Name')
param devCenterName string

@description('Projects')
param projects array

@description('DevBox Definitions')
param devBoxDefinitions array

@description('Network Connections')
param networkConnections array

@description('Projects Resoure')
module deployDevCenterProject 'devCenterProjectResource.bicep' = [
  for (project,i) in projects: {
    name: 'Project-${project[i].name}'
    params: {
      devCenterName: devCenterName
      name: project[i].name
      tags: project[i].tags
      devBoxDefinitions: devBoxDefinitions
      networkConnectionName: networkConnections[i]
    }
  }
]

