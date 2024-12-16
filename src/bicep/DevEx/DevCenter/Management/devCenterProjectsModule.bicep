@description('Dev Center Name')
param devCenterName string

@description('Contoso Projects Info')
param contosoProjectsInfo array

@description('Contoso Dev Center Projects Catalogs Info')
param contosoProjectsCatalogsInfo array

@description('Contoso Dev Center Network Connection Name ')
param networkConnections array

@description('Contoso Dev Center DevBox Definitions Info ')
param devBoxDefinitionsInfo array

@description('Contoso Dev Center Projects')
module contosoDevCenterProjects 'projectResource.bicep' = [for (contosoProject,i) in contosoProjectsInfo: {
  name: 'Project-${contosoProject[i].name}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenterName
    name: contosoProject[i].name
    tags: contosoProject[i].tags
    devBoxDefinitionsInfo: devBoxDefinitionsInfo
    devCenterProjectCatalogInfo: contosoProjectsCatalogsInfo[0]
    networkConnectionName: networkConnections[0].name
  }
}
]
