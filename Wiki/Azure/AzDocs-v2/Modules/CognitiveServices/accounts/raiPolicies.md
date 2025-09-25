# raiPolicies

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="contentFilter">contentFilter</a>  | <pre>{</pre> |  | Content filter configuration for RAI policies | 

## Synopsis
Creating a Responsible AI (RAI) policy for an existing Cognitive Services account

## Description
Creating a Responsible AI policy for an existing Cognitive Services account with the given specifications. This is typically used for configuring content filtering policies for Azure OpenAI accounts.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| accountName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the existing Cognitive Services account where the RAI policy will be created. |
| policyName | string | <input type="checkbox" checked> | Length between 1-64 | <pre></pre> | The name of the RAI policy to create. |
| mode | string | <input type="checkbox"> | `'Default'` or `'Blocking'` | <pre>'Default'</pre> | The mode of the RAI policy. |
| basePolicyName | string | <input type="checkbox"> | None | <pre>''</pre> | The base policy name to inherit from (if using Default mode). |
| contentFilters | contentFilter[] | <input type="checkbox"> | None | <pre>[]</pre> | Array of content filters to apply. Each filter should have the following structure:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'Violence'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;severityThreshold: 'Low' &#124; 'Medium' &#124; 'High'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;blocking: true &#124; false<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;enabled: true &#124; false<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;source: 'Prompt' &#124; 'Completion'<br>&nbsp;&nbsp;&nbsp;}<br>] |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| policyName | string | The name of the created RAI policy |
| policyResourceId | string | The resource ID of the created RAI policy |

## Examples
<pre>
module customRaiPolicy 'br:contosoregistry.azurecr.io/cognitiveservices/accounts/raipolicies:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'rai-policy')
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
    ]
  }
}
</pre>
<p>Creates a custom RAI policy with low violence threshold in an existing Azure OpenAI account</p>

## Links
- [Bicep Microsoft.CognitiveServices accounts/raiPolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts/raipolicies?pivots=deployment-language-bicep)<br>
- [Azure OpenAI Content Filtering](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/content-filter)
