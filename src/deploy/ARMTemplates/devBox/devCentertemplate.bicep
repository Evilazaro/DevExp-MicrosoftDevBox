param devCenterName string = ''
param networkConnectionId string = ''
param computeGalleryId string = ''
param location string = ''
param networkConnectionName string = ''
param userIdentityId string = ''
param computeGalleryImageName string = ''

resource devCenter 'Microsoft.DevCenter/devcenters@2023-10-01-preview' = {
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

resource devCenterName_quickstart_devbox_tasks 'Microsoft.DevCenter/devcenters/catalogs@2023-10-01-preview' = {
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

resource devCenterName_networkConnection 'Microsoft.DevCenter/devcenters/attachednetworks@2024-05-01-preview' = {
  parent: devCenter
  name: '${networkConnectionName}'
  properties: {
    networkConnectionId: networkConnectionId
  }
}

resource devCenterName_computeGalleryImage 'Microsoft.DevCenter/devcenters/galleries@2024-05-01-preview' = {
  parent: devCenter
  name: '${computeGalleryImageName}'
  properties: {
    galleryResourceId: computeGalleryId
  }
}
