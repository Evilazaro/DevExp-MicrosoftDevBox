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
    securityRules: [
      for subnet in subnets: [
        {
          name: 'Allow-SSH'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '22'
            sourceAddressPrefix: subnet.addressPrefix
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 100
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow-HTTP'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '80'
            sourceAddressPrefix: subnet.addressPrefix
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 110
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow-HTTPS'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: subnet.addressPrefix
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 120
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow-UDP'
          properties: {
            protocol: 'Udp'
            sourcePortRange: '*'
            destinationPortRange: '53'
            sourceAddressPrefix: subnet.addressPrefix
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 130
            direction: 'Inbound'
          }
        }
      ]
    ]
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

@description('The ID of the virtual network')
output virtualNetworkId string = virtualNetwork.id

@description('The name of the virtual network')
output name string = name

@description('Subnets of the virtual network')
output subnets array = virtualNetwork.properties.subnets
