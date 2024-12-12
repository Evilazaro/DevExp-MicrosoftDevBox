@description('Dev Center Name')
param devCenterName string

var catalogs = [
  {
    name: 'catalog1'
    uri: 'https://github.com/Evilazaro/DevExp-MicrosoftDevBox.git'
    branch: 'main'
    path: '/customizations/tasks'
    syncType: 'Scheduled'
    type: 'GitHub'
  }
  {
    name: 'catalog2'
    uri: 'https://github.com/Evilazaro/DevExp-MicrosoftDevBox.git'
    branch: 'main'
    path: '/customizations/tasks'
    syncType: 'Scheduled'
    type: 'GitHub'
  }
  {
    name: 'catalog3'
    uri: 'https://github.com/Evilazaro/DevExp-MicrosoftDevBox.git'
    branch: 'main'
    path: '/customizations/tasks'
    syncType: 'Scheduled'
    type: 'GitHub'
  }
  {
    name: 'catalog4'
    uri: 'https://github.com/Evilazaro/DevExp-MicrosoftDevBox.git'
    branch: 'main'
    path: '/customizations/tasks'
    syncType: 'Scheduled'
    type: 'GitHub'
  }
]

@description('Tags')
var tags = {
  idp: 'DevEx'
  source: 'InfrastructureAsCode'
  platform: 'Azure'
  versionControl: 'PlatformSourceCode'
  environmentConfiguration: 'EnvironmentConfiguration'
  environmentTypeVersion: '2024-10-01-preview'
  environmentTypeSource: 'DevCenter'
}

@description('Deploy Catalogs')
module deployCatalog 'catalogResource.bicep' = [
  for catalog in catalogs: {
    name: 'Catalog-${catalog.name}' 
    params: {
      name: catalog.name
      tags: tags
      devCenterName: devCenterName
      syncType: catalog.syncType
      type: catalog.type
      uri: catalog.uri
      branch: catalog.branch
      path: catalog.path
    }
  }
]
