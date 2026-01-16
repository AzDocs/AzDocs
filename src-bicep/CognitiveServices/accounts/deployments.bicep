/*
.SYNOPSIS
Creating a deployment for an existing Cognitive Services account (e.g., OpenAI model deployment)
.DESCRIPTION
Creating a deployment for an existing Cognitive Services account with the given specifications. This is typically used for deploying models to Azure OpenAI accounts.
.EXAMPLE
<pre>
module gpt4Deployment 'br:contosoregistry.azurecr.io/cognitiveservices/accounts/deployments:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 52), 'gpt4-deploy')
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
</pre>
<p>Creates a GPT-4o model deployment in an existing Azure OpenAI account</p>
.LINKS
- [Bicep Microsoft.CognitiveServices accounts/deployments](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts/deployments?pivots=deployment-language-bicep)
- [Azure OpenAI Model Deployments](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource)
*/

// ================================================= Parameters =================================================
@description('The name of the existing Cognitive Services account where the deployment will be created.')
@minLength(2)
@maxLength(64)
param accountName string

@description('The name of the deployment to create.')
@minLength(1)
@maxLength(64)
param deploymentName string

@description('The model name to deploy (e.g., gpt-4o, gpt-35-turbo, text-embedding-ada-002).')
param modelName string

@description('The model version to deploy.')
param modelVersion string

@description('The model format. Defaults to OpenAI.')
@allowed([
  'OpenAI'
])
param modelFormat string = 'OpenAI'

@description('The SKU capacity (token rate limit) for the deployment.')
@minValue(1)
@maxValue(1000)
param skuCapacity int = 250

@description('The SKU name for the deployment.')
@allowed([
  'Standard'
  'GlobalStandard'
  'DataZoneStandard'
])
param skuName string = 'DataZoneStandard'

@description('The version upgrade option for the deployment.')
@allowed([
  'OnceNewDefaultVersionAvailable'
  'OnceCurrentVersionExpired'
  'NoAutoUpgrade'
])
param versionUpgradeOption string = 'OnceNewDefaultVersionAvailable'

@description('The RAI (Responsible AI) policy name to apply to this deployment.')
param raiPolicyName string = 'Microsoft.DefaultV2'

// ================================================= Existing Resources =================================================
@description('Reference to the existing Cognitive Services account')
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: accountName
}

// ================================================= Resources =================================================
@description('Create the model deployment')
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = {
  parent: cognitiveServicesAccount
  name: deploymentName
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  properties: {
    model: {
      format: modelFormat
      name: modelName
      version: modelVersion
    }
    versionUpgradeOption: versionUpgradeOption
    raiPolicyName: raiPolicyName
  }
}

// ================================================= Outputs =================================================
@description('The name of the created deployment')
output deploymentName string = modelDeployment.name

@description('The resource ID of the created deployment')
output deploymentResourceId string = modelDeployment.id

@description('The capacity of the created deployment')
output deploymentCapacity int = modelDeployment.sku.capacity
