@description('Dev Center Name')
param devCenterName string

@description('Catalog Name')
param name string

@description('Catalog Sync Type')
@allowed([
  'Manual'
  'Scheduled'
])
param syncType string

@description('Tags')
param tags object

@description('Catalog Type')
@allowed([
  'GitHub'
  'AzureDevOps'
])
param type string

@description('Catalog Type')
param uri string 

@description('Catalog Branch')
param branch string

@description('Catalog Path')
param path string

@description('Dev Center Resource')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Catalog Resource')
resource devCenterCatalog 'Microsoft.DevCenter/devcenters/catalogs@2024-10-01-preview' = {
  name: name
  parent: devCenter
  properties: {
    tags: tags
    syncType: syncType
    gitHub: (type == 'GitHub' ? {
        uri: uri
        branch: branch
        path: path
    } : null)
    adoGit: (type == 'AzureDevOps' ? {
        uri: uri
        branch: branch
        path: path
    } : null)
  }
}

@description('Catalog Resource ID')
output id string = devCenterCatalog.id

@description('Catalog Resource Name')
output catalogName string = devCenterCatalog.name

@description('Catalog Resource Tags')
output catalogTags object = devCenterCatalog.properties.tags

@description('Catalog Resource Sync Type')
output catalogSyncType string = devCenterCatalog.properties.syncType
