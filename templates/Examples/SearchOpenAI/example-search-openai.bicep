/*
.SYNOPSIS
Example template showing how to deploy Azure Search Service with Azure OpenAI for RAG scenarios
.DESCRIPTION
This template demonstrates how to use the Search and CognitiveServices modules to deploy a complete
RAG (Retrieval-Augmented Generation) setup including Azure Search Service and Azure OpenAI.
.EXAMPLE
This template can be deployed using:
az deployment group create --resource-group myResourceGroup --template-file example-search-openai.bicep --parameters @parameters.json
*/

// ================================================= Parameters =================================================
@description('The name prefix for all resources')
@minLength(2)
@maxLength(20)
param namePrefix string = 'rag'

@description('The environment name (e.g., dev, test, prod)')
param environmentName string = 'dev'

@description('Specifies the Azure location where the resources should be created.')
param location string = resourceGroup().location

@description('The tags to apply to all resources.')
param tags object = {
  Environment: environmentName
  Service: 'RAG-Platform'
}

@description('The azure resource id of the log analytics workspace for diagnostics.')
param logAnalyticsWorkspaceResourceId string = ''

@description('The SKU for the Search Service.')
@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
param searchServiceSku string = 'basic'

@description('Enable semantic search capabilities.')
@allowed([
  'disabled'
  'free'
  'standard'
])
param semanticSearch string = 'free'

// ================================================= Variables =================================================
var searchServiceName = '${namePrefix}-search-${environmentName}'
var openAiAccountName = '${namePrefix}-openai-${environmentName}'

// ================================================= Resources =================================================

// Create the Azure Search Service
module searchService '../../../src-bicep/Search/searchServices.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'search')
  params: {
    searchServiceName: searchServiceName
    location: location
    skuName: searchServiceSku
    tags: tags
    publicNetworkAccess: 'enabled'
    semanticSearch: semanticSearch
    replicaCount: 1
    partitionCount: 1
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}

// Create the Azure OpenAI account
module openAiAccount '../../../src-bicep/CognitiveServices/accounts.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'openai')
  params: {
    accountName: openAiAccountName
    location: location
    kind: 'OpenAI'
    skuName: 'S0'
    tags: tags
    publicNetworkAccess: 'Enabled'
    networkAclsDefaultAction: 'Allow'
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}

// Deploy text embedding model for RAG
module embeddingDeployment '../../../src-bicep/CognitiveServices/accounts/deployments.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 42), 'embedding-deploy')
  params: {
    accountName: openAiAccount.outputs.accountName
    deploymentName: 'text-embedding-3-large'
    modelName: 'text-embedding-3-large'
    modelVersion: '1'
    skuCapacity: 250
    skuName: 'GlobalStandard'
    versionUpgradeOption: 'NoAutoUpgrade'
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

// Deploy GPT-4o model for generation
module gpt4oDeployment '../../../src-bicep/CognitiveServices/accounts/deployments.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 47), 'gpt4o-deploy')
  params: {
    accountName: openAiAccount.outputs.accountName
    deploymentName: 'gpt-4o'
    modelName: 'gpt-4o'
    modelVersion: '2024-11-20'
    skuCapacity: 250
    skuName: 'GlobalStandard'
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

// Create a storage account for document storage (optional)
module storageAccount '../../../src-bicep/Storage/storageAccounts.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'stg')
  params: {
    storageAccountName: '${replace(namePrefix, '-', '')}docs${environmentName}'
    location: location
    storageAccountKind: 'StorageV2'
    storageAccountSku: 'Standard_LRS'
    defaultBlobAccessTier: 'Hot'
    tags: tags
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}

// ================================================= Outputs =================================================
@description('The name of the created Search Service')
output searchServiceName string = searchService.outputs.searchServiceName

@description('The endpoint of the created Search Service')
output searchServiceEndpoint string = searchService.outputs.searchServiceEndpoint

@description('The resource ID of the created Search Service')
output searchServiceResourceId string = searchService.outputs.searchServiceResourceId

@description('The name of the created OpenAI account')
output openAiAccountName string = openAiAccount.outputs.accountName

@description('The endpoint of the created OpenAI account')
output openAiEndpoint string = openAiAccount.outputs.endpoint

@description('The resource ID of the created OpenAI account')
output openAiResourceId string = openAiAccount.outputs.accountResourceId

@description('The name of the created storage account')
output storageAccountName string = storageAccount.outputs.storageAccountName

@description('Configuration summary for the RAG setup')
output ragConfiguration object = {
  searchService: {
    name: searchService.outputs.searchServiceName
    endpoint: searchService.outputs.searchServiceEndpoint
    sku: searchServiceSku
    semanticSearch: semanticSearch
  }
  openAI: {
    name: openAiAccount.outputs.accountName
    endpoint: openAiAccount.outputs.endpoint
    embeddingModel: 'text-embedding-3-large'
    generationModel: 'gpt-4o'
  }
  storage: {
    name: storageAccount.outputs.storageAccountName
  }
}
