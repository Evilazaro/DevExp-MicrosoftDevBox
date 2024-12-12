@description('Dev Center Name')
param devCenterName string

@description('Projects')
param projects array

@description('Projects Resoure')
module deployDevCenterProject 'devCenterProjectResource.bicep' = [
  for project in projects: {
    name: project.name
    params: {
      devCenterName: devCenterName
      name: project.name
      tags: project.tags
    }
  }
]
