
param location string = resourceGroup().location
param environment string
param projectName string
param repositoryName string
param accountName string
param collaborationBranch string
param rootFolder string
param hostName string
param tenant string
param keyVaultLinkedServiceName string
param integrationRuntimeName string 
param secretName string


param factoryName string = 'ADFCExcercise4'
param adfLocation string = 'westus'
param sqlServerName string = 'extsksqlserver112'
param sqlAdminUser string = 'sqladminuser'
param sqlAdminPwd string = 'sqladminpassword123!'
param sqlDatabaseName string = 'extskdatabase112'
param keyVaultName string = 'extskkeyvault1112'
param storaagename string = 'AzureBlobStorage1'
param storageAccountName string = 'extskstorageaccount112'

param tenantId string = '16b3c013-d300-468d-ac64-7eda0820b6d3'
// param subscriptionId string = 'ac616a3b-53be-4cbf-961c-5467b1590718'


@secure()
param SqlDatabaseLinkedService_connectionString string = 'Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source={sqlServerName}.database.windows.net;Initial Catalog={sqlDatabaseName};Authentication=ActiveDirectoryManagedIdentity'
param KeyVaultLinkedService_properties_typeProperties_baseUrl string = 'https://{keyVaultName.vault.azure.net/'
param SqlDatabaseLinkedService_properties_typeProperties_databaseName string = '{sqlServerName}/{sqlDatabaseName}'
param AzureBlobStorage1_properties_typeProperties_serviceEndpoint string = 'https://extskstorageaccount112.blob.core.windows.net/'

param managedIdentityName string = 'adfusermi'
param resourceGroupName string = 'RG-CEI-Datafactory1'

//var factoryId = 'Microsoft.DataFactory/factories/${factoryName}'
var _repositoryType = 'FactoryVSTSConfiguration' 

var azDevopsRepoConfiguration = {
  accountName: accountName
  repositoryName: repositoryName
  collaborationBranch: collaborationBranch
  rootFolder: rootFolder  
  type: _repositoryType
  projectName: projectName
}


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: adfLocation
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: adfLocation
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: factoryName
  location: adfLocation
  properties: {
   
    repoConfiguration: (environment == 'Development') ? azDevopsRepoConfiguration : {}
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: sqlServerName
  location: adfLocation
  properties: {
    administratorLogin: sqlAdminUser
    administratorLoginPassword: sqlAdminPwd
    version: '12.0'
   
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2019-06-01-preview' = {
  name: sqlDatabaseName
  location: adfLocation
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  parent: sqlServer
}




resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01'  ={
  name: keyVaultName
  location: adfLocation
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
  
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: 'e83f8f38-3aa9-417f-8fb2-9632da6e7609'
        permissions: {
          keys: ['get', 'list' ]
          secrets: [ 'get', 'list' ]
        }
      }
    ]
  }
}
/*resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing ={
  name: keyVaultName
}
*/

resource factoryName_KeyVaultLinkedService 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/KeyVaultLinkedService'
  properties: {
    annotations: []
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: KeyVaultLinkedService_properties_typeProperties_baseUrl
      credential: {
        referenceName: 'Datastdumi'
        type: 'CredentialReference'
      }
    }
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {  //[]
        '${managedIdentity.id}': {}
      }
    }
  }
 dependsOn: [
  factoryName_Datastdumi
  adf
]
}

resource factoryName_SqlDatabaseLinkedService 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/SqlDatabaseLinkedService'
  properties: {
    annotations: []
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: SqlDatabaseLinkedService_connectionString
      credential: {
        referenceName: 'Datastdumi'
        type: 'CredentialReference'
      }
      serverName: 'extsksqlserver112'
      databaseName: SqlDatabaseLinkedService_properties_typeProperties_databaseName
      authenticationType: 'ManagedIdentity'
     
    }
  }
  dependsOn: [
  factoryName_Datastdumi
  adf
]
}

resource factoryName_Datastdumi 'Microsoft.DataFactory/factories/credentials@2018-06-01' = {
  name: '${factoryName}/Datastdumi'
  properties: {
    type: 'ManagedIdentity'
    typeProperties: {
     //'${managedIdentity.id}': {}
     //resourceUri: '${managedIdentity.id}'
    }
  }
  dependsOn: []
}



resource factoryName_AzureBlobStorage1 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/AzureBlobStorage1'
  properties: {
    annotations: []
    type: 'AzureBlobStorage'
    typeProperties: {
      serviceEndpoint: AzureBlobStorage1_properties_typeProperties_serviceEndpoint
      accountKind: 'StorageV2'
      credential: {
        referenceName: 'Datastdumi'
        type: 'CredentialReference'
      }
    }
  }
  dependsOn: [
  factoryName_Datastdumi
  adf
]
}

resource awsRds 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/awsRds'
  properties: {
    description: 'AWS RDS'
    annotations: []
    type: 'Oracle'
    typeProperties: {
      connectionString: 'host=ORCL;port=1521;serviceName=ORCL;user id=SVC_JDE_ADF'
      password: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: keyVaultLinkedServiceName
          type: 'LinkedServiceReference'
        }
        secretName: secretName
      }
    }
    connectVia: {
      referenceName: integrationRuntimeName
      type: 'IntegrationRuntimeReference'
    }
  }
}
