@description('Dev Center Name')
param devCenterName string

@description('Network Connection Name')
param name string

@description('Network Connection Resource Group Name')
param networkConnectionResourceGroupName string

@description('Network Connection Resource')
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-10-01-preview' existing = {
  name: name
  scope: resourceGroup(networkConnectionResourceGroupName)
}

@description('Dev Center Resource')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Network Connection Attachment resource')
resource networkConnectionAttachment 'Microsoft.DevCenter/devcenters/attachednetworks@2024-10-01-preview' = {
  name: networkConnection.name
  parent: devCenter
  properties: {
    networkConnectionId: networkConnection.id
  }
}
