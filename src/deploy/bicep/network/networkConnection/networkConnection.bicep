
@description('Network Connection Name')
param virtualNetworkConnectionName string

@description('Subnet ID')
param virtualNetwortkName string

@description('Tags for the Network Connection')
param tags object

@description('Gets the information from the existing virtual network')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: virtualNetwortkName
}

@description('Deploy a network connection to Azure')
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-08-01-preview' = {
  name: virtualNetworkConnectionName
  location: resourceGroup().location
  tags: tags
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: virtualNetwork.properties.subnets[0].id
  }
}
