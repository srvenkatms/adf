param dataFactoryName string 
param location string = resourceGroup().location
param environment string

param projectName string
param repositoryName string
param accountName string
param collaborationBranch string
param rootFolder string
param hostName string
param tenant string

var _repositoryType = 'FactoryVSTSConfiguration' 

var azDevopsRepoConfiguration = {
  accountName: accountName
  repositoryName: repositoryName
  collaborationBranch: collaborationBranch
  rootFolder: rootFolder  
  type: _repositoryType
  projectName: projectName
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' =  {
  name: dataFactoryName
  location: location
  properties: {
    repoConfiguration: azDevopsRepoConfiguration
  }
}
