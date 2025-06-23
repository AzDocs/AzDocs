/*
.SYNOPSIS
Creating Defender for AI settings for an existing Cognitive Services account
.DESCRIPTION
Creating Defender for AI settings for an existing Cognitive Services account with the given specifications. This is used to configure Microsoft Defender for AI on Azure OpenAI accounts.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.CognitiveServices accounts/defenderForAISettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts/defenderforaisettings?pivots=deployment-language-bicep)
- [Microsoft Defender for AI](https://learn.microsoft.com/en-us/azure/ai-services/responsible-use-of-ai-overview)
*/

// ================================================= Parameters =================================================
@description('The name of the existing Cognitive Services account where the Defender for AI settings will be configured.')
@minLength(2)
@maxLength(64)
param accountName string

@description('The state of Defender for AI.')
@allowed([
  'Enabled'
  'Disabled'
])
param state string = 'Disabled'

// ================================================= Existing Resources =================================================
@description('Reference to the existing Cognitive Services account')
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: accountName
}

// ================================================= Resources =================================================
@description('Configure Defender for AI settings')
resource defenderForAISettings 'Microsoft.CognitiveServices/accounts/defenderForAISettings@2025-04-01-preview' = {
  parent: cognitiveServicesAccount
  name: 'Default'
  properties: {
    state: state
  }
}

// ================================================= Outputs =================================================
@description('The state of Defender for AI')
output defenderState string = defenderForAISettings.properties.state

@description('The resource ID of the Defender for AI settings')
output defenderResourceId string = defenderForAISettings.id
