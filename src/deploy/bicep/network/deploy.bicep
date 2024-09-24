param vnetName string
param subnetName string
param networkConnectionName string

module deployVnet 'deployVnet.bicep' = {
  name: 'deployVnet'
  params: {
    vnetName: vnetName
    subnetName: subnetName
  }
}

output vnetName string = deployVnet.outputs.subnetId
output subnetId string = deployVnet.outputs.vnetId
