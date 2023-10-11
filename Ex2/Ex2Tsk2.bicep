resource keyVaultLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${dataFactory.name}-keyVaultLinkedService'
  parent: dataFactory
  properties: {
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: keyVault.properties.vaultUri
      authenticationType: 'ManagedServiceIdentity'
    }
  }
  dependsOn: [
    dataFactory
    keyVault
  ]
}



resource adfLsBlob 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${dataFactory.name}-BlobLinkedService'
  parent: dataFactory
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: '${'DefaultEndpointsProtocol=https;AccountName='}${storageAccountName}${';AccountKey='}${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}${';EndpointSuffix=core.windows.net'}'
    }
  }
 
  dependsOn: [
    dataFactory
   
  ]
}

resource adfLsSqlDb 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${dataFactory.name}-SQLLinkedService'
  parent: dataFactory
  properties: {
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: '${'Server='}${sqlServer.properties.fullyQualifiedDomainName}${';Database='}${databaseName}${';User ID='}${sqlAdminLogin}${';Password='}${sqlAdminPassword}${';Encrypt=true;Connection Timeout=30;'}'
    }
  }
}
output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
output dataFactoryIdentityPrincipalId string = dataFactory.identity.principalId
