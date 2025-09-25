/*
.SYNOPSIS
Example template showing how to deploy Azure OpenAI with models and policies
.DESCRIPTION
This template demonstrates how to use the CognitiveServices modules to deploy a complete Azure OpenAI setup
including the account, model deployments, RAI policies, and Defender for AI settings.
.EXAMPLE
This template can be deployed using:
az deployment group create --resource-group myResourceGroup --template-file example-openai.bicep --parameters @parameters.json
*/

// ================================================= Parameters =================================================
@description('The name prefix for all resources')
@minLength(2)
@maxLength(20)
param namePrefix string = 'openai'

@description('The environment name (e.g., dev, test, prod)')
param environmentName string = 'dev'

@description('Specifies the Azure location where the resources should be created.')
param location string = resourceGroup().location

@description('The tags to apply to all resources.')
param tags object = {
  Environment: environmentName
  Service: 'OpenAI'
}

@description('The azure resource id of the log analytics workspace for diagnostics.')
param logAnalyticsWorkspaceResourceId string = ''

// ================================================= Variables =================================================
var openAiAccountName = '${namePrefix}-${environmentName}'

// ================================================= Resources =================================================

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

// Create a custom RAI policy for stricter content filtering
module customRaiPolicy '../../../src-bicep/CognitiveServices/accounts/raiPolicies.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'rai-custom')
  params: {
    accountName: openAiAccount.outputs.accountName
    policyName: 'CustomContentFilter'
    mode: 'Default'
    basePolicyName: 'Microsoft.DefaultV2'
    contentFilters: [
      {
        name: 'Violence'
        severityThreshold: 'Low'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Hate'
        severityThreshold: 'Low'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Sexual'
        severityThreshold: 'Low'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Selfharm'
        severityThreshold: 'Low'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Violence'
        severityThreshold: 'Low'
        blocking: true
        enabled: true
        source: 'Completion'
      }
      {
        name: 'Hate'
        severityThreshold: 'Low'
        blocking: true
        enabled: true
        source: 'Completion'
      }
      {
        name: 'Sexual'
        severityThreshold: 'Low'
        blocking: true
        enabled: true
        source: 'Completion'
      }
      {
        name: 'Selfharm'
        severityThreshold: 'Low'
        blocking: true
        enabled: true
        source: 'Completion'
      }
    ]
  }
}

// Deploy GPT-4o model
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

// Deploy o3-mini model with custom RAI policy
module o3MiniDeployment '../../../src-bicep/CognitiveServices/accounts/deployments.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'o3mini-deploy')
  params: {
    accountName: openAiAccount.outputs.accountName
    deploymentName: 'o3-mini'
    modelName: 'o3-mini'
    modelVersion: '2025-01-31'
    skuCapacity: 250
    skuName: 'GlobalStandard'
    raiPolicyName: 'CustomContentFilter'
  }
  dependsOn: [
    customRaiPolicy
  ]
}

// Deploy text embedding model
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

// Configure Defender for AI (disabled by default for cost reasons)
module defenderForAI '../../../src-bicep/CognitiveServices/accounts/defenderForAISettings.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 40), 'defender-ai')
  params: {
    accountName: openAiAccount.outputs.accountName
    state: 'Disabled'
  }
}

// ================================================= Outputs =================================================
@description('The name of the created OpenAI account')
output openAiAccountName string = openAiAccount.outputs.accountName

@description('The endpoint of the created OpenAI account')
output openAiEndpoint string = openAiAccount.outputs.endpoint

@description('The resource ID of the created OpenAI account')
output openAiResourceId string = openAiAccount.outputs.accountResourceId

@description('The custom subdomain of the OpenAI account')
output customSubDomain string = openAiAccount.outputs.customSubDomainName
