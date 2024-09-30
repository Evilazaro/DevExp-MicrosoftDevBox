param vnetName string

resource vNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
}

output vnetId string = vNet.id
output addressPrefix string = vNet.properties.addressSpace.addressPrefixes[0]
output vnetName string = vNet.name
output subnetId string = vNet.properties.subnets[0].id

resource deployNetworkConnection 'Microsoft.DevCenter/networkconnections@2023-04-01' = {
  name: format('{0}-networkConnection', vnetName)
  location: resourceGroup().location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: vNet.properties.subnets[0].id
  }
  dependsOn: [
    vNet
  ]
}

output networkConnectionName string = deployNetworkConnection.name
output networkConnectionId string = deployNetworkConnection.id
