@description('Projects Info')
param contosoProjectsInfo array

@description('Dev Center Name')
param devCenterName string

@description('Project Resource')
module projects 'projectResource.bicep' = [for project in contosoProjectsInfo: {
  name: 'Project-${project.name}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenterName
    name: project.name
    tags: project.tags
  }
}
]
