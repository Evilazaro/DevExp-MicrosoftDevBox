@description('Dev Center Name')
param devCenterName string

@description('Projects')
param projects array

@description('DevBox Definitions')
param devBoxDefinitions array

@description('Projects Resoure')
module deployDevCenterProject 'devCenterProjectResource.bicep' = [
  for project in projects: {
    name: 'Project-${project.name}'
    params: {
      devCenterName: devCenterName
      name: project.name
      tags: project.tags
      devBoxDefinitions: devBoxDefinitions
    }
  }
]

