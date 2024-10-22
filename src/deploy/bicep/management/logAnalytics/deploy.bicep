
@description('Solution Name')
param solutionName string

@description('The name of the log analytics workspace')
var logAnalyticsWorkspaceName = format('{0}-logAnalytics', solutionName)

@description('The tags of the log analytics workspace')
var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'Management'
}

@description('Deploy the log analytics workspace')
module logAnalytics 'logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: logAnalyticsWorkspaceName
    tags: tags
  }
}
