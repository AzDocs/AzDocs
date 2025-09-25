# defenderForAISettings

Target Scope: resourceGroup

## Synopsis
Creating Defender for AI settings for an existing Cognitive Services account

## Description
Creating Defender for AI settings for an existing Cognitive Services account with the given specifications. This is used to configure Microsoft Defender for AI on Azure OpenAI accounts.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| accountName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the existing Cognitive Services account where the Defender for AI settings will be configured. |
| state | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | The state of Defender for AI. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| defenderState | string | The state of Defender for AI |
| defenderResourceId | string | The resource ID of the Defender for AI settings |

## Examples
<pre>
module defenderSettings 'br:contosoregistry.azurecr.io/cognitiveservices/accounts/defenderforaisettings:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 40), 'defender-ai')
  params: {
    accountName: openAiAccount.outputs.accountName
    state: 'Enabled'
  }
}
</pre>
<p>Enables Microsoft Defender for AI on an existing Azure OpenAI account</p>

## Links
- [Bicep Microsoft.CognitiveServices accounts/defenderForAISettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts/defenderforaisettings?pivots=deployment-language-bicep)<br>
- [Microsoft Defender for AI](https://learn.microsoft.com/en-us/azure/ai-services/responsible-use-of-ai-overview)
