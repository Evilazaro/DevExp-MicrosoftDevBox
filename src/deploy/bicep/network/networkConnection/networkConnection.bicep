
@description('Network Connection Name')
param name string

@description('Subnet Id')
param subnetId string

@description('Tags for the Network Connection')
param tags object

@description('Deploy a network connection to Azure')
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-08-01-preview' = {
  name: name
  location: resourceGroup().location
  tags: tags
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
  }
}
