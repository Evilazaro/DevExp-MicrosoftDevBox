@description('Projects')
param projects array

@description(' Dev Box Definitions')
param devBoxDefinitions array

module pool 'devBoxPoolResource.bicep' = [
  for project in projects: {
    name: 'Project-${project.name}'
    params: {
      projectName: project.name
      devBoxDefinitions: devBoxDefinitions
      networkConnectionName: project.networkConnectionName
    }
  }
]
