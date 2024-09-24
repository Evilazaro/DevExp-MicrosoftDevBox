param devCenterName string
param devBoxDefinitionName string
param location string
param networkConnectionName string
param identityName string
param computeGalleryName string
param computeGalleryImageName string


var identityId = format('/subscriptions/{0}/resourcegroups/{1}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{2}', subscription().subscriptionId, resourceGroup().name, identityName)

@description('Deploying DevCenter')
resource deployDevCenter 'Microsoft.DevCenter/devcenters@2024-02-01' = {
  name: devCenterName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {}
}

output devCenterId string = deployDevCenter.id
output devCenterName string = deployDevCenter.name
output devCenterIdentityId string = identityId

// resource devCenterName_quickstart_devbox_tasks 'Microsoft.DevCenter/devcenters/catalogs@2024-02-01' = {
//   parent: deployDevCenter
//   name: 'quickstart-devbox-tasks'
//   properties: {
//     gitHub: {
//       uri: 'https://github.com/Evilazaro/MicrosoftDevBox.git'
//       branch: 'main'
//       path: 'src/customizations/tasks'
//     }
//   }
// }

// output devCenterName_quickstart_devbox_tasks_id string = devCenterName_quickstart_devbox_tasks.id
// output devCenterName_quickstart_devbox_tasks_name string = devCenterName_quickstart_devbox_tasks.name

// resource devCenterName_networkConnection 'Microsoft.DevCenter/devcenters/attachednetworks@2024-02-01' = {
//   parent: deployDevCenter
//   name: networkConnectionName
//   properties: {
//     networkConnectionId: resourceId('Microsoft.Network/connections', networkConnectionName)
//   }
// }

// output devCenterName_networkConnection_id string = devCenterName_networkConnection.id
// output devCenterName_networkConnection_name string = devCenterName_networkConnection.name

// resource devCenterName_computeGalleryImage 'Microsoft.DevCenter/devcenters/galleries@2024-02-01' = {
//   parent: deployDevCenter
//   name: computeGalleryName
//   properties: {
//     galleryResourceId: format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DevCenter/devcenters/{2}/galleries/{3}', subscription().subscriptionId, resourceGroup().name, devCenterName, computeGalleryName)
//   }
// }

// output devCenterName_computeGalleryImage_id string = devCenterName_computeGalleryImage.id
// output devCenterName_computeGalleryImage_name string = devCenterName_computeGalleryImage.name

// resource devBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
//   name: devBoxDefinitionName
//   location: resourceGroup().location
//   parent: deployDevCenter
//   properties: {
//     hibernateSupport: 'true'
//     imageReference: {
//       id: format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DevCenter/devcenters/{2}/galleries/Default/images/{3}', subscription().subscriptionId, resourceGroup().name, devCenterName, computeGalleryImageName)
//     }
//     osStorageType: 'ssd_512gb'
//     sku: {
//       capacity: 10
//       family: 'string'
//       name: 'general_i_32c128gb512ssd_v2'
//     }
//   }
// }

// output devBoxDefinitionId string = devBoxDefinition.id
// output devBoxDefinitionName string = devBoxDefinition.name

// resource project 'Microsoft.DevCenter/projects@2024-02-01' = {
//   name: 'eShop'
//   location: resourceGroup().location
//   properties: {
//     description: 'eShop Commerce'
//     devCenterId: deployDevCenter.id
//     maxDevBoxesPerUser: 10
//   }
// }

// output projectId string = project.id
// output projectName string = project.name

// resource projectPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
//   name: 'eShopProjectPool'
//   location: resourceGroup().location
//   parent: project
//   properties: {
//     devBoxDefinitionName: devBoxDefinition.name
//     licenseType: 'Windows_Client'
//     localAdministrator: 'Enabled'
//     networkConnectionName: devCenterName_networkConnection.name
//     stopOnDisconnect: {
//       gracePeriodMinutes: 60
//       status: 'Disabled'
//     }
//   }
// }

// output projectPoolId string = projectPool.id
// output projectPoolName string = projectPool.name

