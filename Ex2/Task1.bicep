// Ex 2 Task 1
resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  name: 'default'
  /*properties: {
    publicAccess: 'None'
  }*/
  parent: storageAccount
}

  resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' =  {
    name: containerName
   
   /* properties: {
      publicAccess: 'None'
      metadata: {}
    }*/
    parent: blobServices
  }
   

resource database 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: databaseName
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    edition: 'Standard'
    maxSizeBytes: 1073741824
    requestedServiceObjectiveName: 'S0'
  }
  parent: sqlServer
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      name: keyVaultSkuName
      family: keyVaultSkuFamily
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: dataFactory.identity.principalId
        permissions: {
          keys: ['get', 'list' ]
          secrets: [ 'get', 'list' ]
        }
      }
    ]
  }

}
// Add connection string to KV
resource sqlConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: 'sqlConnectionString'
  properties: {
    value: '${'Server='}${sqlServer.properties.fullyQualifiedDomainName}${';Database='}${databaseName}${';User ID='}${sqlAdminLogin}${';Password='}${sqlAdminPassword}${';Encrypt=true;Connection Timeout=30;'}'
  }
  dependsOn: [
    sqlServer
  ]
  parent: keyVault
}

resource storageConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: 'storageConnectionString'
  properties: {
    value: '${'DefaultEndpointsProtocol=https;AccountName='}${storageAccountName}${';AccountKey='}${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}${';EndpointSuffix=core.windows.net'}'
  }
  dependsOn: [
    storageAccount
  ]
  parent: keyVault
}
// End of Ex2 task 1
