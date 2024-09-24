param vnetName string
param subnetName string
param networkConnectionName string
param customRoleName string
param identityId string

module networkCustomRoleAssignment '../identity/customRoleAssignment.bicep' = {
  name: 'networkCustomRoleAssignment'
  params: {
    customRoleName: customRoleName
    identityId: identityId
  }
}


module deployVnet 'deployVnet.bicep' = {
  name: 'deployVnet'
  params: {
    vnetName: vnetName
    subnetName: subnetName
  }
}

output vnetName string = deployVnet.outputs.subnetId
output subnetId string = deployVnet.outputs.vnetId
