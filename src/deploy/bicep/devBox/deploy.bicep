@description('Solution Name')
param solutionName string

@description('Management Resource Group Name')
param managementResourceGroupName string

@description('Teams and Projects for the Dev Center')
var projects = [
  {
    name: 'eShop'
    description: 'eShop Reference Application - AdventureWorks'
    networkConnectionName: 'eShop-con'
    catalog: {
      name: 'eShop'
      type: 'gitHub'
      uri: 'https://github.com/Evilazaro/eShop.git'
      branch: 'main'
      path: '/.devcenter/customizations/tasks'
    }
  }
  {
    name: 'contosoTraders'
    description: 'Contoso Traders Reference Application - Contoso'
    networkConnectionName: 'contosoTraders-con'
    catalog: {
      name: 'contosoTraders'
      type: 'gitHub'
      uri: 'https://github.com/Evilazaro/ContosoTraders.git'
      branch: 'main'
      path: '/customizations/tasks'
    }
  }
]

@description('The name of the Dev Center')
var devCenterName = format('{0}DevCenter', solutionName)

@description('The name of the network resource group')
var networkResourceGroupName = format('{0}-Network-rg', solutionName)

var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'DevBox'
}

@description('Deploy the Managed Identity')
module identity '../identity/deploy.bicep' = {
  name: 'identity'
  params: {
    solutionName: solutionName
  }
}

@description('Deploy the Compute Gallery')
module computeGallery './computeGallery/deployComputeGallery.bicep' = {
  name: 'computeGallery'
  params: {
    solutionName: solutionName
    tags: tags
  }
  dependsOn: [
    identity
  ]
}

@description('Teams and Projects for the Dev Center')
var catalogInfo = {
  name: '${devCenterName}-catalog'
  type: 'gitHub'
  uri: 'https://github.com/Evilazaro/DevExp-MicrosoftDevBox.git'
  branch: 'main'
  path: '/customizations/tasks'
}

@description('Deploy the Dev Center')
module devCenter 'devCenter/deployDevCenter.bicep' = {
  name: 'devCenter'
  params: {
    name: devCenterName
    identityName: identity.outputs.identityName
    computeGalleryName: computeGallery.outputs.computeGalleryName
    projects: projects
    networkResourceGroupName: networkResourceGroupName
    catalogInfo: catalogInfo
    tags: tags
  }
  dependsOn: [
    computeGallery
  ]
}

var logAnalyticsWorkspaceName = '${solutionName}-logAnalytics'


@description('Existing Log Analytics Workspace')
resource devCenterLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(managementResourceGroupName)
}

@description('Existent DevCenter')
resource deployedDevCenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Dev Center Log Analytics Diagnostic Settings')
resource devCenterLogAnalyticsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: devCenterLogAnalyticsWorkspace.name
  scope: deployedDevCenter
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: devCenterLogAnalyticsWorkspace.id
  }
  dependsOn: [
    deployedDevCenter
    devCenterLogAnalyticsWorkspace
  ]
}

@description('Dev Center Log Analytics Diagnostic Settings Id')
output devCenterLogAnalyticsDiagnosticSettingsId string = devCenterLogAnalyticsDiagnosticSettings.id

@description('Dev Center Log Analytics Diagnostic Settings Name')
output devCenterLogAnalyticsDiagnosticSettingsName string = devCenterLogAnalyticsDiagnosticSettings.name
