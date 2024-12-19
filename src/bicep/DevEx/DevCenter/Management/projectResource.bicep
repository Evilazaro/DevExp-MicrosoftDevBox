@description('Dev Center Name')
param devCenterName string

@description('Project Name')
param name string

@description('Tags')
param tags object

@description('Project Catalog Info')
param projectCatalogsInfo array

@description('Dev Box Definitions')
param devBoxDefinitions array

@description('Network Connection Name')
param networkConnectionName string

@description('Role Definition Ids')
param roleDefinitionIds array

// @description('Project Environment Types Info')
// param projectEnvironmentTypesInfo array

@description('Dev Center')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Dev Center Project Resource')
resource devCenterProject 'Microsoft.DevCenter/projects@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  identity: {
    type:  'SystemAssigned'
  }
  properties: {
    displayName: name
    devCenterId: devCenter.id
    catalogSettings: {
      catalogItemSyncTypes: [
        'EnvironmentDefinition'
        'ImageDefinition'
      ]
    }
    maxDevBoxesPerUser: 3
    description: 'Dev Center Project - ${name}'
  }
  tags: tags
}
@description('Role Assignment Resource')
module roleAssignment '../../../identity/roleAssignmentResource.bicep' = {
  name: 'roleAssignment-${name}'
  scope: subscription()
  params: {
    principalId: devCenterProject.identity.principalId
    roleDefinitionIds: roleDefinitionIds
  }
}

@description('Project Catalog Resource')
resource projectCatalogs 'Microsoft.DevCenter/projects/catalogs@2024-10-01-preview' = [for projectCataLog in projectCatalogsInfo:  {
  name: '${projectCataLog.catalogName}'
  parent: devCenterProject
  properties: {
    gitHub: {
      uri: projectCataLog.uri
      branch: projectCataLog.branch
      path: projectCataLog.path
    }
  }
}
]

@description('Dev Center Project Pools')
resource devCenterProjectPools 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = [
  for pool in devBoxDefinitions: {
    name: '${name}-${pool.name}-pool'
    parent: devCenterProject
    location: resourceGroup().location
    properties: {
      displayName: '${name}-${pool.name}-pool'
      devBoxDefinitionName: pool.name
      licenseType: 'Windows_Client'
      localAdministrator: 'Enabled'
      networkConnectionName: networkConnectionName
    }
  }
]

// @description('Project Environment Types Resources')
// resource projectEnvironmentTypes 'Microsoft.DevCenter/projects/environmentTypes@2024-10-01-preview' = [for environmentType in projectEnvironmentTypesInfo: {
//   name: '${environmentType.name}-environmentType'
//   parent: devCenterProject
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     displayName: environmentType.name
//     deploymentTargetId: resourceId('Microsoft.Resources/subscriptions', subscription().subscriptionId)
//     status: 'Enabled'
//   }  
// }]

