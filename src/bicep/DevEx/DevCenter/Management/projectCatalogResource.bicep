@description('Project Name')
param projectName string

@description('Project Catalog Info')
param projectCatalogInfo object

@description('Project')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview'existing = {
  name: projectName
  scope: resourceGroup()
}

@description('Project Catalog Resource')
resource projectCatalog 'Microsoft.DevCenter/projects/catalogs@2024-10-01-preview' = {
  name: projectCatalogInfo.catalogName
  parent: project
  properties: {
    gitHub: {
      uri: projectCatalogInfo.uri
      branch: projectCatalogInfo.branch
      path: projectCatalogInfo.path
    }
    syncType: 'Scheduled'
  }
}

@description('Project Catalog Resource ID')
output projectCatalogId string = projectCatalog.id

@description('Project Catalog Resource Name')
output projectCatalogName string = projectCatalog.name

@description('Project Catalog URI') 
output projectCatalogUri string = projectCatalog.properties.adoGit.uri

@description('Project Catalog Branch')
output projectCatalogBranch string = projectCatalog.properties.adoGit.branch

@description('Project Catalog Path')
output projectCatalogPath string = projectCatalog.properties.adoGit.path

