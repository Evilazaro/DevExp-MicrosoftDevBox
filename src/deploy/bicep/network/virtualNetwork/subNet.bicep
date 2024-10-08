@description('Create a subnet in a virtual network')
param virtualNetworkName string

@description('The address prefix of the subnet')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('The ID of the network security group')
param nsgId string

@description('The virtual network to deploy the subnet to')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: virtualNetworkName
}

@description('The name of the subnet')
var subnetName = '${virtualNetworkName}-subnet'

@description('Deploy a subnet to a virtual network')
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    networkSecurityGroup: {
      id: nsgId
    }
  }
  parent: virtualNetwork
}

@description('The ID of the subnet')
output subnetId string = subnet.id

@description('The name of the subnet')
output subnetName string = subnetName
