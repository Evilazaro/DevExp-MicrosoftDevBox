@description('Virtual Network Name')
param virtualNetworkName string 

@description('Subnet Name for the Virtual Network')
param subnetName string

@description('Virtual Network Resource Group Name')
param virtualNetworkResourceGroupName string 

@description('Domain Join Type')
@allowed([
  'None'
  'AzureADJoin'
  'HybridADJoin'
])
param domainJoinType string 

@description('Existing virtual network')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
  name: virtualNetworkName
  scope:resourceGroup(virtualNetworkResourceGroupName)
}

@description('Existing subnet resource')
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' existing = {
  name: subnetName
  parent: virtualNetwork
}

@description('The network connection resource')
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-10-01-preview' = {
  name: uniqueString(resourceGroup().id,'${virtualNetworkName}-${subnetName}')
  location: resourceGroup().location
  properties: {
    subnetId: subnet.id
    domainJoinType: domainJoinType
  }
}

@description('The ID of the network connection')
output networkConnectionId string = networkConnection.id

@description('The name of the network connection')
output networkConnectionName string = networkConnection.name

@description('The domain join type of the network connection')
output domainJoinType string = networkConnection.properties.domainJoinType

@description('Virtual Network Resource Group Name')
output networkingResourceGroupName string = networkConnection.properties.networkingResourceGroupName

@description('Subnet ID')
output subnetId string = networkConnection.properties.subnetId
 