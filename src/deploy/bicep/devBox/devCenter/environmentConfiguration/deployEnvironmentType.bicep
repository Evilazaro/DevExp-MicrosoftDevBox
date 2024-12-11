@description('Dev Center Name')
param devCenterName string

@description('Environment Types')
var environments = [
  {
    name: 'dev'
    tags: tags
  }
  {
    name: 'staging'
    tags: tags
  }
  {
    name: 'prod'
    tags: tags
  }
  {
    name:'UAT'
    tags: tags
  }
]

@description('Tags')
var tags = {
  division: 'PlatformEngineeringTeam-DevEx'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  landingZone: 'DevBox'
}

@description('Deploy Environment Type')
module deployEnvironmentType 'environmentTypes.bicep' = [
  for environment in environments: {
    name: 'EnvironmentType-${environment.name}'
    params: {
      devCenterName: devCenterName
      name: environment.name
      tags: environment.tags
    }
  }
]

@description('Environment Type Names')
output environmentTypeNames array = [for environment in environments: environment.name]
