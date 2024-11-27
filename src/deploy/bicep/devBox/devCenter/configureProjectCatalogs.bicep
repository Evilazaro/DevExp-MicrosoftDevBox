param projectInfo object

@description('Existent Project')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' existing = {
  name: projectInfo.name
}

@description('Attache the DevCenter Catalog to the Project')
resource projectCatalog 'Microsoft.DevCenter/projects/catalogs@2024-08-01-preview' = {
  name: projectInfo.catalog.name
  parent: project
  properties: {
    gitHub: {
      uri: projectInfo.catalog.uri
      branch: projectInfo.catalog.branch
      path: projectInfo.catalog.path
    }
    syncType: 'Scheduled'
  }
}
