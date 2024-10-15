param catalog object
param devCenterName string

@description('Existent DevCenter')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}

@description('Create DevCenter Catalogs with DevBox Tasks')
resource devCenterCatalogs 'Microsoft.DevCenter/devcenters/catalogs@2024-02-01' = {
  parent: devCenter
  name: catalog.name
  properties: {
    gitHub: {
      uri: catalog.uri
      branch: catalog.branch
      path: catalog.path
    }
  }
}

output devCenterName_quickstart_devbox_tasks_id string = devCenterCatalogs.id
output devCenterName_quickstart_devbox_tasks_name string = devCenterCatalogs.name
