param devCenterName string
param devBoxDefinitionName string
param computeGalleryId string
param location string
param networkConnectionName string
param userIdentityId string
param computeGalleryImageName string

resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' = {
  name: devCenterName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentityId}': {}
    }
  }
  properties: {}
}

output devCenterId string = devCenter.id
output devCenterName string = devCenter.name

resource devCenterName_quickstart_devbox_tasks 'Microsoft.DevCenter/devcenters/catalogs@2024-02-01' = {
  parent: devCenter
  name: 'quickstart-devbox-tasks'
  properties: {
    gitHub: {
      uri: 'https://github.com/Evilazaro/MicrosoftDevBox.git'
      branch: 'main'
      path: 'src/customizations/tasks'
    }
  }
}

output devCenterName_quickstart_devbox_tasks_id string = devCenterName_quickstart_devbox_tasks.id
output devCenterName_quickstart_devbox_tasks_name string = devCenterName_quickstart_devbox_tasks.name

resource devCenterName_networkConnection 'Microsoft.DevCenter/devcenters/attachednetworks@2024-02-01' = {
  parent: devCenter
  name: networkConnectionName
  properties: {
    networkConnectionId: resourceId('Microsoft.Network/networkConnections', networkConnectionName)
  }
}

output devCenterName_networkConnection_id string = devCenterName_networkConnection.id
output devCenterName_networkConnection_name string = devCenterName_networkConnection.name

resource devCenterName_computeGalleryImage 'Microsoft.DevCenter/devcenters/galleries@2024-02-01' = {
  parent: devCenter
  name: computeGalleryImageName
  properties: {
    galleryResourceId: computeGalleryId
  }
}

output devCenterName_computeGalleryImage_id string = devCenterName_computeGalleryImage.id
output devCenterName_computeGalleryImage_name string = devCenterName_computeGalleryImage.name

resource devBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  name: devBoxDefinitionName
  location: resourceGroup().location
  parent: devCenter
  properties: {
    hibernateSupport: 'true'
    imageReference: {
      id: format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DevCenter/devcenters/{2}/galleries/Default/images/{3}', subscription().subscriptionId, resourceGroup().name, devCenterName, computeGalleryImageName)
    }
    osStorageType: 'ssd_512gb'
    sku: {
      capacity: 10
      family: 'string'
      name: 'general_i_32c128gb512ssd_v2'
    }
  }
}

output devBoxDefinitionId string = devBoxDefinition.id
output devBoxDefinitionName string = devBoxDefinition.name

resource project 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: 'eShop'
  location: resourceGroup().location
  properties: {
    description: 'eShop Commerce'
    devCenterId: devCenter.id
    maxDevBoxesPerUser: 10
  }
}

output projectId string = project.id
output projectName string = project.name

resource projectPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: 'eShopProjectPool'
  location: resourceGroup().location
  parent: project
  properties: {
    devBoxDefinitionName: devBoxDefinition.name
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: devCenterName_networkConnection.name
    stopOnDisconnect: {
      gracePeriodMinutes: 60
      status: 'Disabled'
    }
  }
}

output projectPoolId string = projectPool.id
output projectPoolName string = projectPool.name

