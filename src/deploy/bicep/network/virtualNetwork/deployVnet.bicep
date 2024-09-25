param vnetName string
param subnetName string

var addressPrefixes = [
  '10.0.0.0/16'
]
var subnetPrefix = '10.0.0.0/24'

@description('Deploy Virtual Network and Subnet')
resource deployVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

output vnetId string = deployVirtualNetwork.id
output subnetId string = deployVirtualNetwork.properties.subnets[0].id
output subnetName string = deployVirtualNetwork.properties.subnets[0].name
output addressPrefix string = deployVirtualNetwork.properties.subnets[0].properties.addressPrefix
output vnetName string = deployVirtualNetwork.name

