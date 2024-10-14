@description('Solution Name')
param solutionName string

var identityName = format('{0}-identity', solutionName)
var customRoleName = format('{0}-customRole', identityName)
var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'Identity'
}

@description('Deploy the identity')
module identity 'deployIdentity.bicep' = {
  name: 'deployIdentity'
  params: {
    location: resourceGroup().location
    identityName: identityName
    tags: tags
  }
}

@description('Identity Name')
output identityName string = identity.outputs.identityName

@description('Deploy the custom role')
module customRole 'deployCustomRole.bicep' = {
  name: 'deployCustomRole'
  params: {
    customRoleName: customRoleName
  }
  dependsOn: [
    identity
  ]
}

@description('Deploy the custom role assignment')
module identityCustomRoleAssignment 'customRoleAssignment.bicep' = {
  name: 'identityCustomRoleAssignment'
  params: {
    customRoleName: customRole.outputs.customRoleName
    identityId: identity.outputs.identityPrincipalId
    customRoleId: customRole.outputs.customRoleId
  }
  dependsOn: [
    customRole
  ]
}

