@description('The name of the subnet')
param name string

@description('The name of the virtual network')
param vnetName string

@description('The address prefix of the subnet')
param subnetAddressPrefix string

@description('The Id of the Network Security Group')
param nsgId string

@description('Existing Virtual Network Name')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
  name: vnetName
  scope: resourceGroup()
}

@description('Deploys a subnet to an existing Virtual Network')
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  name: name
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddressPrefix
    networkSecurityGroup: {
      id: nsgId
    }
  }
}
