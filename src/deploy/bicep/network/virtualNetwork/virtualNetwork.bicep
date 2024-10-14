@description('The name of the virtual network')
param name string

@description('The location of the virtual network')
param location string = resourceGroup().location

@description('The address prefix of the virtual network')
param addressPrefix array

@description('The subnets of the virtual network')
param subnets array

@description('The tags of the virtual network')
param tags object

@description('Deploy a NSG with rules for all subnets')
module nsg '../../security/networkSecurityGroup.bicep' = {
  name: 'nsg'
  params: {
    name: name
    securityRules:[]
    tags: tags
  }
}

@description('Deploy a virtual network to Azure')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefix
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          networkSecurityGroup: {
            id: nsg.outputs.nsgId
          }
        }
      }
    ]
  }
  tags: tags
  dependsOn: [
    nsg
  ]
}

@description('Virtual Network Name')
output vnetName string = virtualNetwork.name

@description('Virtual Network Id')
output vnetId string = virtualNetwork.id
