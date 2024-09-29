param devCenterName string


resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}


@description('Create DevCenter Catalogs with DevBox Tasks')
resource devCenterCatalogs 'Microsoft.DevCenter/devcenters/catalogs@2024-02-01' = {
  parent: devCenter
  name: 'DevCenterCatalog'
  properties: {
    gitHub: {
      uri: 'https://github.com/Evilazaro/MicrosoftDevBox.git'
      branch: 'main'
      path: 'src/customizations/tasks'
    }
  }
}

output devCenterName_quickstart_devbox_tasks_id string = devCenterCatalogs.id
output devCenterName_quickstart_devbox_tasks_name string = devCenterCatalogs.name
