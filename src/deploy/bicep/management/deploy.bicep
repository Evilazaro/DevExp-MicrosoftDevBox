param solutionName string

var logAnalyticsWorkspaceName = format('{0}-logAnalytics', solutionName)
var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'Management'
}

module logAnalytics 'logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    tags: tags
  }
}
