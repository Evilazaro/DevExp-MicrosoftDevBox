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
    projectCatalogInfo: contosoProject.catalog
  }
}
]
