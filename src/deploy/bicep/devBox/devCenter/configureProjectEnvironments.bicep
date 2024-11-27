param projectName string
param identityName string

resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' existing = {
  name: projectName
}

resource identity 'Microsoft.ManagedIdentity/identities@2023-07-31-preview' existing = {
  name: identityName
}

resource projectDevEnvironment 'Microsoft.DevCenter/projects/environmentTypes@2023-04-01' = {
  name: format('{0}DevEnvironment', projectName)
  location: resourceGroup().location
  tags: {
    tagName1: 'Development'
    tagName2: projectName
  }
  parent: project
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    creatorRoleAssignment: {
      roles: {}
    }
    deploymentTargetId: resourceId(subscription().subscriptionId, tenant().tenantId)
    status: 'Enabled'
    userRoleAssignments: {}
  }
}

output projectDevEnvironmentId string = projectDevEnvironment.id
output projectDevEnvironmentName string = projectDevEnvironment.name
