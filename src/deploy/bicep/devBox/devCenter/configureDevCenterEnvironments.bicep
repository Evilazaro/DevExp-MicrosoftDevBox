param devCenterName string

resource deployDevCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
}

@description('Create DevCenter Development Environment for the eShop Project')
resource devCenterDevEnvironment 'Microsoft.DevCenter/devcenters/environmentTypes@2024-10-01-preview' = {
  parent: deployDevCenter
  name: 'Development'
  properties: {
    displayName: 'Development'
  }
}

output devCenterDevEnvironmentId string = devCenterDevEnvironment.id
output devCenterDevEnvironmentName string = devCenterDevEnvironment.name

@description('Create DevCenter Staging Environment for the eShop Project')
resource devCenterStagingEnvironment 'Microsoft.DevCenter/devcenters/environmentTypes@2024-10-01-preview' = {
  parent: deployDevCenter
  name: 'Staging'
  properties: {
    displayName: 'Staging'
  }
}

output devCenterStagingEnvironmentId string = devCenterStagingEnvironment.id
output devCenterStagingEnvironmentName string = devCenterStagingEnvironment.name
