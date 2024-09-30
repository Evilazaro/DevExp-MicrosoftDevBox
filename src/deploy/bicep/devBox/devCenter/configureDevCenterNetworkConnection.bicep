param devCenterName string
param networkResourceGroupName string
param networkConnectionName string

resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-02-01' existing = {
  name: networkConnectionName
}

resource deployDevCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
}

@description('Create DevCenter Network Connection')
resource devCenterNetworkConnection 'Microsoft.DevCenter/devcenters/attachednetworks@2024-02-01' = {
  parent: deployDevCenter
  name: networkConnection.name
  properties: {
    networkConnectionId: format(
      '/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DevCenter/networkConnections/{2}',
      subscription().subscriptionId,
      networkResourceGroupName,
      networkConnection.name
    )
  }
}

output devCenterName_networkConnection_id string = devCenterNetworkConnection.id
output devCenterName_networkConnection_name string = devCenterNetworkConnection.name
