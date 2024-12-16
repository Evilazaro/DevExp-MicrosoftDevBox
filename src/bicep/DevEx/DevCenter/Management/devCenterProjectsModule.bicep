@description('Dev Center Name')
param devCenterName string

@description('Contoso Projects Info')
param contosoProjectsInfo array

// @description('Contoso Dev Center Projects Catalogs Info')
// param contosoProjectsCatalogsInfo object

// @description('Contoso Dev Center Network Connection Name ')
// param networkConnectionName string

// @description('Contoso Dev Center DevBox Definitions Info ')
// param devBoxDefinitionsInfo array

@description('Contoso Projects Tags')
param tags object

@description('Contoso Dev Center Projects')
module contosoDevCenterProjects 'projectResource.bicep' =  [for project in contosoProjectsInfo: {
  name: 'Project-${project.name}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenterName
    name: project.name
    tags: tags
  }
}
]
