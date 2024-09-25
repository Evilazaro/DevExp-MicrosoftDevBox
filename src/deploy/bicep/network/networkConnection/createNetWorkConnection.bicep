param name string
param subnetId string
param location string

resource DeployNetworkConnection 'Microsoft.DevCenter/networkconnections@2023-04-01' = {
  name: name
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
    networkingResourceGroupName: 'NI_${name}_${location}'
  }
}

output networkConnectionName string = DeployNetworkConnection.name
output networkConnectionId string = DeployNetworkConnection.id
