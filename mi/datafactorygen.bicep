/*
This Bicep file defines the resources for a data processing solution in Azure. 

It includes the following resources:
- Parameters for the deployment, including location, environment, project name, repository name, account name, collaboration branch, root folder, host name, tenant, and various service names.
- A Managed Identity for the Data Factory.
- A Storage Account for storing data.
- A Data Factory for orchestrating and automating data movement and transformation.
- A SQL Server and SQL Database for storing and managing structured data.
- A Key Vault for storing secrets.
- Linked Services for the Key Vault, SQL Database, Azure Blob Storage, and an AWS RDS Oracle database in the Data Factory.

Each resource is defined with its necessary properties and dependencies. The Linked Services are configured with the necessary connection strings, credentials, and other properties for connecting to the respective services. The Managed Identity is used for authenticating the Data Factory with the services it connects to.

Please replace the placeholders in the parameters and properties with your actual values before deploying this Bicep file.
*/
// Define the location of the resource group
param location string = resourceGroup().location

// Define the environment
param environment string

// Define the project name
param projectName string

// Define the repository name
param repositoryName string

// Define the account name
param accountName string

// Define the collaboration branch
param collaborationBranch string

// Define the root folder
param rootFolder string

// Define the host name
param hostName string

// Define the tenant
param tenant string

// Define the Key Vault Linked Service name
param keyVaultLinkedServiceName string

// Define the integration runtime name
param integrationRuntimeName string 

// Define the secret name
param secretName string

// Define the factory name
param factoryName string = 'ADFCExcercise4'

// Define the location of the Data Factory
param adfLocation string = 'westus'

// Define the SQL Server name
param sqlServerName string = 'extsksqlserver112'

// Define the SQL admin user
param sqlAdminUser string = 'sqladminuser'

// Define the SQL admin password
param sqlAdminPwd string = 'sqladminpassword123!'

// Define the SQL Database name
param sqlDatabaseName string = 'extskdatabase112'

// Define the Key Vault name
param keyVaultName string = 'extskkeyvault1112'

// Define the storage name
param storaagename string = 'AzureBlobStorage1'

// Define the storage account name
param storageAccountName string = 'extskstorageaccount112'

// Define the tenant ID
param tenantId string = '16b3c013-d300-468d-ac64-7eda0820b6d3'

// Define the SQL Server new flag
param SqlServernew bool = true

// Define the connection string for the SQL Database Linked Service
@secure()
param SqlDatabaseLinkedService_connectionString string = 'Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source={sqlServerName}.database.windows.net;Initial Catalog={sqlDatabaseName};Authentication=ActiveDirectoryManagedIdentity'

// Define the base URL for the Key Vault Linked Service
param KeyVaultLinkedService_properties_typeProperties_baseUrl string = 'https://{keyVaultName.vault.azure.net/'

// Define the database name for the SQL Database Linked Service
param SqlDatabaseLinkedService_properties_typeProperties_databaseName string = '{sqlServerName}/{sqlDatabaseName}'

// Define the service endpoint for the Azure Blob Storage
param AzureBlobStorage1_properties_typeProperties_serviceEndpoint string = 'https://extskstorageaccount112.blob.core.windows.net/'

// Define the name of the managed identity
param managedIdentityName string = 'adfusermi'

// Define the name of the resource group
param resourceGroupName string = 'RG-CEI-Datafactory1'

// Define the repository type
var _repositoryType = 'FactoryVSTSConfiguration' 

// Define the Azure DevOps repository configuration
var azDevopsRepoConfiguration = {
  accountName: accountName
  repositoryName: repositoryName
  collaborationBranch: collaborationBranch
  rootFolder: rootFolder  
  type: _repositoryType
  projectName: projectName
}

// Define the managed identity resource
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: adfLocation
}

// Define the storage account resource
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

// Define the Data Factory resource
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

// Define the SQL Server resource
resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' = if (SqlServernew) {
  name: sqlServerName
  location: adfLocation
  properties: {
    administratorLogin: sqlAdminUser
    administratorLoginPassword: sqlAdminPwd
    version: '12.0'
  }
}

// Define the existing SQL Server resource
resource sqlServerexisting 'Microsoft.Sql/servers@2019-06-01-preview' existing = if (!SqlServernew) {
  name: sqlServerName
}

// Define the SQL Database resource
resource sqlDatabase 'Microsoft.Sql/servers/databases@2019-06-01-preview' = if (SqlServernew) {
  name: sqlDatabaseName
  location: adfLocation
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  parent: sqlServer
}

// Define the Key Vault resource
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01'  ={
  name: keyVaultName
  location: adfLocation
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
  
    // Define the access policies for the Key Vault
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

// Define the Key Vault Linked Service for the Data Factory
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
      userAssignedIdentities: {
        '${managedIdentity.id}': {}
      }
    }
  }
  dependsOn: [
    factoryName_Datastdumi
    adf
  ]
}

// Define the SQL Database Linked Service for the Data Factory
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

// Define the Managed Identity credential for the Data Factory

resource factoryName_Datastdumi 'Microsoft.DataFactory/factories/credentials@2018-06-01' = {
  name: '${factoryName}/Datastdumi'
  properties: {
    type: 'ManagedIdentity'
    typeProperties: {
      resourceId: '/subscriptions/${subscriptionId}/resourcegroups/${resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adfusermi'
    }
  }
  dependsOn: []
}

// Define the Azure Blob Storage Linked Service for the Data Factory
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

// Define the AWS RDS Linked Service for the Data Factory
resource awsRds 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/awsRds' // The name of the Linked Service
  properties: {
    description: 'AWS RDS' // Description of the Linked Service
    annotations: [] // Annotations for the Linked Service
    type: 'Oracle' // The type of the Linked Service
    typeProperties: {
      connectionString: 'host=ORCL;port=1521;serviceName=ORCL;user id=SVC_JDE_ADF' // Connection string to the Oracle database
      password: {
        type: 'AzureKeyVaultSecret' // The type of the password
        store: {
          referenceName: keyVaultLinkedServiceName // The reference name of the Key Vault where the password is stored
          type: 'LinkedServiceReference' // The type of the reference
        }
        secretName: secretName // The name of the secret where the password is stored
      }
    }
    connectVia: {
      referenceName: integrationRuntimeName // The reference name of the Integration Runtime
      type: 'IntegrationRuntimeReference' // The type of the reference
    }
  }
}
