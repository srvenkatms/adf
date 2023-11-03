
using 'datafactorygen.bicep'

// devops config section
param projectName   = 'CICD with Azure Data Factory'
param repositoryName  = 'ADFDataRepo-2'
param accountName  = 'ana2lavi'
param collaborationBranch  = 'main'
param rootFolder  = '/'
param hostName  = ''
param tenant = '8c2cffcd-8683-40e2-963d-80812966a1b7'
param environment = 'Development'

param factoryName = 'ADFCExcercise4'
param adfLocation = 'westus'
param sqlServerName  = 'extsksqlserver112'
param sqlAdminUser  = 'sqladminuser'
param sqlAdminPwd  = 'sqladminpassword123!'
param sqlDatabaseName  = 'extskdatabase112'
param keyVaultName  = 'extskkeyvault1112'
param storaagename  = 'AzureBlobStorage1'
param storageAccountName  = 'extskstorageaccount112'

param tenantId  = '16b3c013-d300-468d-ac64-7eda0820b6d3'

param keyVaultLinkedServiceName  = 'keyVaultLinkedService'
param integrationRuntimeName  = 'shir-np-JDE-ORCL'
param secretName  = 'ORCL-AWS-RDS-DV-PY'
