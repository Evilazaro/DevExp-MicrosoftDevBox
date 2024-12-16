@description('Dev Center Name')
param devCenterName string

@description('Network Connections Created')
param networkConnectionsCreated array

@description('Dev Center Resource')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Network Connection Attachment resource')
resource networkConnectionAttachment 'Microsoft.DevCenter/devcenters/attachednetworks@2024-10-01-preview' = [
  for networkConnection in networkConnectionsCreated: {
    name: networkConnection.name
    parent: devCenter
    properties: {
      networkConnectionId: networkConnection.id
    }
  }
]

@description('Output network attachments created')
output networkConnectionAttachmentsCreated array = [
  for (networkConnection, i) in networkConnectionsCreated: {
    name: networkConnectionAttachment[i].name
    id: networkConnectionAttachment[i].id
    networkConnectionId: networkConnectionAttachment[i].properties.networkConnectionId
  }
]
