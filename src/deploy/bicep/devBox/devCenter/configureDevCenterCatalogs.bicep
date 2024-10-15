param devCenterName string
param projectInfo object

@description('Existent DevCenter')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}

@description('Attache the DevCenter Catalog to the DevCenter')
resource projectCatalog 'Microsoft.DevCenter/devcenters/catalogs@2024-08-01-preview' = {
  name: '${projectInfo.catalog.name}-catalog'
  parent: devCenter
  properties: {
    gitHub: {
      uri: projectInfo.catalog.uri
      branch: projectInfo.catalog.branch
      path: projectInfo.catalog.path
    }
  }
}
