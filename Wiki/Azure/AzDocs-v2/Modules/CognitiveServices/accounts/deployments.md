# deployments

Target Scope: resourceGroup

## Synopsis
Creating a deployment for an existing Cognitive Services account (e.g., OpenAI model deployment)

## Description
Creating a deployment for an existing Cognitive Services account with the given specifications. This is typically used for deploying models to Azure OpenAI accounts.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| accountName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the existing Cognitive Services account where the deployment will be created. |
| deploymentName | string | <input type="checkbox" checked> | Length between 1-64 | <pre></pre> | The name of the deployment to create. |
| modelName | string | <input type="checkbox" checked> | None | <pre></pre> | The model name to deploy (e.g., gpt-4o, gpt-35-turbo, text-embedding-ada-002). |
| modelVersion | string | <input type="checkbox" checked> | None | <pre></pre> | The model version to deploy. |
| modelFormat | string | <input type="checkbox"> | `'OpenAI'` | <pre>'OpenAI'</pre> | The model format. Defaults to OpenAI. |
| skuCapacity | int | <input type="checkbox"> | Value between 1-1000 | <pre>250</pre> | The SKU capacity (token rate limit) for the deployment. |
| skuName | string | <input type="checkbox"> | `'Standard'` or `'GlobalStandard'` or `'DataZoneStandard'` | <pre>'DataZoneStandard'</pre> | The SKU name for the deployment. |
| versionUpgradeOption | string | <input type="checkbox"> | `'OnceNewDefaultVersionAvailable'` or `'OnceCurrentVersionExpired'` or `'NoAutoUpgrade'` | <pre>'OnceNewDefaultVersionAvailable'</pre> | The version upgrade option for the deployment. |
| raiPolicyName | string | <input type="checkbox"> | None | <pre>'Microsoft.DefaultV2'</pre> | The RAI (Responsible AI) policy name to apply to this deployment. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| deploymentName | string | The name of the created deployment |
| deploymentResourceId | string | The resource ID of the created deployment |
| deploymentCapacity | int | The capacity of the created deployment |

## Examples
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

## Links
- [Bicep Microsoft.CognitiveServices accounts/deployments](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts/deployments?pivots=deployment-language-bicep)<br>
- [Azure OpenAI Model Deployments](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource)
