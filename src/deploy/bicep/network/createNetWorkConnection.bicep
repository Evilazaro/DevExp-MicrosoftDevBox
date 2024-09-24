param name string
param subnetId string
param location string

resource networkConnection 'Microsoft.DevCenter/networkconnections@2023-04-01' = {
  name: name
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
    networkingResourceGroupName: 'NI_${name}_${location}'
  }
}

output networkConnectionName string = networkConnection.name
output networkConnectionId string = networkConnection.id
