@description('The name of the network security group')
param nsgName string = 'myNsg'

@description('The security rules of the network security group')
param securityRules array = []

@description('The tags of the network security group')
param tags object

@description('Deploy a network security group to Azure')
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: nsgName
  location: resourceGroup().location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}

@description('The ID of the network security group')
output nsgId string = nsg.id
