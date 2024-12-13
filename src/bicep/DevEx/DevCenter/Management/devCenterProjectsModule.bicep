@description('Dev Center Name')
param devCenterName string

@description('Contoso Projects Info')
param contosoProjectsInfo array

@description('Contoso Dev Center Projects')
module contosoDevCenterProjects 'devCenterProjectResource.bicep' = [for contosoProject in contosoProjectsInfo: {
  name: 'Project-${contosoProject.name}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenterName
    name: contosoProject.name
    tags: contosoProject.tags
  }
}
]

@description('Output Contoso Dev Center Projects created')
output outPutcontosoProjectsCreated array = [for (contosoProject,i) in contosoProjectsInfo: {
  name: contosoDevCenterProjects[i].outputs.devCenterProjectName
  id: contosoDevCenterProjects[i].outputs.devCenterProjectId
}]


// @description('Project Catalog')
// module projectCatalog 'projectCatalogResource.bicep' = [for (contosoProject,i) in contosoProjectsInfo: {
//   name: 'ProjectCatalog-${contosoProject.name}'
//   scope: resourceGroup()
//   params: {
//     projectName: contosoDevCenterProjects[i].outputs.devCenterProjectName
//     projectCatalogInfo: contosoProject[i].projectCatalog
//   }
//   dependsOn: [
//     contosoDevCenterProjects
//   ]
// }
// ]

module propjectCatalog 'projectCatalogResource.bicep' = {
  name: contosoProjectsInfo[0].name
  params: {
    projectCatalogInfo: contosoProjectsInfo[0].projectCatalog
    projectName: contosoDevCenterProjects[0].outputs.devCenterProjectName
  }
}

// @description('Output Project Catalog created')
// output projectCatalogCreated array = [for (contosoProject,i) in contosoProjectsInfo: {
//   name: projectCatalog[i].outputs.projectCatalogName
//   id: projectCatalog[i].outputs.projectCatalogId
//   uri: projectCatalog[i].outputs.projectCatalogUri
//   branch: projectCatalog[i].outputs.projectCatalogBranch
//   path: projectCatalog[i].outputs.projectCatalogPath
// }
// ]

// @description('Output Project Catalogs created')
// output projectCatalogsCreated array = [for (contosoProject,i) in contosoProjectsInfo: {
//   name: projectCatalog[i].outputs.devCenterProjectCatalogCatalogName
//   id: projectCatalog[i].outputs.projectResource.id
//   info: projectCatalog[i].outputs.devCenterProjectCatalogInfo
// }]
