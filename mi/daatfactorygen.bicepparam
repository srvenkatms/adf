using 'datafactorygen.bicep'

// DevOps configuration parameters
param projectName = 'CICD with Azure Data Factory' // The name of the project
param repositoryName = 'ADFDataRepo-2' // The name of the repository
param accountName = 'ana2lavi' // The name of the account
param collaborationBranch = 'main' // The branch for collaboration
param rootFolder = '/' // The root folder for the deployment
param hostName = '' // The host name for the deployment
param tenant = '8c2cffcd-8683-40e2-963d-80812966a1b7' // The tenant for the deployment
param environment = 'Development' // The environment for the deployment

// Data Factory parameters
param factoryName = 'ADFCExcercise4' // The name of the Data Factory

// Location for the resources
param adfLocation = 'westus' // The location for the Data Factory

// SQL Server parameters
param sqlServerName = 'extsksqlserver112' // The name of the SQL Server
param sqlAdminUser = 'sqladminuser' // The username for the SQL Server admin
param sqlAdminPwd = 'sqladminpassword123!' // The password for the SQL Server admin
param sqlDatabaseName = 'extskdatabase112' // The name of the SQL Database

// Key Vault parameters
param keyVaultName = 'extskkeyvault1112' // The name of the Key Vault

// Storage parameters
param storaagename = 'AzureBlobStorage1' // The name of the Azure Blob Storage
param storageAccountName = 'extskstorageaccount112' // The name of the Storage Account

// Tenant ID
param tenantId = '16b3c013-d300-468d-ac64-7eda0820b6d3' // The tenant ID for the deployment

// Linked Service names
param keyVaultLinkedServiceName = 'keyVaultLinkedService' // The name of the Key Vault Linked Service
param integrationRuntimeName = 'shir-np-JDE-ORCL' // The name of the Integration Runtime
param secretName = 'ORCL-AWS-RDS-DV-PY' // The name of the secret in the Key Vault

// Flag to indicate whether a new SQL Server should be created
param SqlServernew = true

param subscriptionId  = 'ac616a3b-53be-4cbf-961c-5467b1590718' // need for mi
