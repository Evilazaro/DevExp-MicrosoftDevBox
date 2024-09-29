param devCenterName string

resource deployDevCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}

@description('Create DevCenter Development Environment for the eShop Project')
resource devCenterDevEnvironment 'Microsoft.DevCenter/devcenters/environmenttypes@2024-02-01' = {
  parent: deployDevCenter
  name: 'Development'
}

output devCenterDevEnvironmentId string = devCenterDevEnvironment.id
output devCenterDevEnvironmentName string = devCenterDevEnvironment.name

@description('Create DevCenter Staging Environment for the eShop Project')
resource devCenterStagingEnvironment 'Microsoft.DevCenter/devcenters/environmenttypes@2024-02-01' = {
  parent: deployDevCenter
  name: 'Staging'
}

output devCenterStagingEnvironmentId string = devCenterStagingEnvironment.id
output devCenterStagingEnvironmentName string = devCenterStagingEnvironment.name
