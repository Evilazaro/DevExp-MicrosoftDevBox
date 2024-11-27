@description('The name of the network security group')
param name string

@description('The security rules of the network security group')
param securityRules array

@description('The tags of the network security group')
param tags object

@description('Deploy a network security group to Azure')
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: '${name}-nsg'
  location: resourceGroup().location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}

@description('Network security group id')
output nsgId string = nsg.id

@description('Network security group name')
output nsgName string = nsg.name
