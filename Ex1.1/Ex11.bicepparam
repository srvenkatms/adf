
using 'datafactory.bicep'

// devops config section
param projectName   = '<<Project Name>>'
param repositoryName  = '<<ADF studio repo name>>'
param accountName  = '<<organization name>>'
param collaborationBranch  = '<<ADF Studio repo name main branch>>'
param rootFolder  = '/'
param hostName  = ''
param tenant = '<<devops AAD tenantID>>'

param dataFactoryName = '<<ADF data Factory name>>'

param environment = 'Development'
