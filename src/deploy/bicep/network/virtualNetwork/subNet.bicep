@description('Create a subnet in a virtual network')
param virtualNetworkName string

@description('The address prefix of the subnet')
param subnetAddressPrefix array

// @description('The ID of the network security group')
// param nsgId string

@description('The virtual network to deploy the subnet to')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: virtualNetworkName
}

@description('Deploy a subnet to a virtual network')
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = [
  for prefix in subnetAddressPrefix: {
    name: prefix.name
    properties: {
      addressPrefix: prefix.addressPrefix
      // networkSecurityGroup: {
      //   id: nsgId
      // }
    }
    parent: virtualNetwork
  }
]
