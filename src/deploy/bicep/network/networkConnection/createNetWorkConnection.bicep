param name string
param subnetId string
param location string

resource deployNetworkConnection 'Microsoft.DevCenter/networkconnections@2023-04-01' = {
  name: name
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
    networkingResourceGroupName: 'NI_${name}_${location}'
  }
}

output networkConnectionName string = deployNetworkConnection.name
output networkConnectionId string = deployNetworkConnection.id
