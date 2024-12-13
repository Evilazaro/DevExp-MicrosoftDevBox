@description('Dev Center Name')
param devCenterName string

@description('Contoso Projects Info')
param contosoProjectsInfo array

@description('Contoso Dev Center Projects')
module contosoDevCenterProjects 'devCenterProjectResource.bicep' = [for contosoProject in contosoProjectsInfo: {
  name: 'Project-${contosoProject.name}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenterName
    name: contosoProject.name
    tags: contosoProject.tags
  }
}
]

@description('Output Contoso Dev Center Projects created')
output contosoProjectsCreated array = [for (contosoProject,i) in contosoProjectsInfo: {
  name: contosoDevCenterProjects[i].outputs.devCenterProjectName
  id: contosoDevCenterProjects[i].outputs.devCenterProjectId
}]
