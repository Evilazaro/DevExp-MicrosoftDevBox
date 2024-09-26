param name string
param subnetId string

resource deployNetworkConnection 'Microsoft.DevCenter/networkconnections@2023-04-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
    networkingResourceGroupName: 'NI_${name}_${resourceGroup().location}' 
  }
}

output networkConnectionName string = deployNetworkConnection.name
output networkConnectionId string = deployNetworkConnection.id
