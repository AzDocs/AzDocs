/*
.SYNOPSIS
Creating a Responsible AI (RAI) policy for an existing Cognitive Services account
.DESCRIPTION
Creating a Responsible AI policy for an existing Cognitive Services account with the given specifications. This is typically used for configuring content filtering policies for Azure OpenAI accounts.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.CognitiveServices accounts/raiPolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts/raipolicies?pivots=deployment-language-bicep)
- [Azure OpenAI Content Filtering](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/content-filter)
*/

// ================================================= User-Defined Types =================================================
@description('Content filter configuration for RAI policies')
type contentFilter = {
  @description('The name of the content filter (e.g., Violence, Hate, Sexual, SelfHarm)')
  name: string

  @description('The severity threshold for the content filter (Low, Medium, High)')
  severityThreshold: string

  @description('Whether the content filter should block content that exceeds the threshold')
  blocking: bool

  @description('Whether the content filter is enabled')
  enabled: bool

  @description('The source to apply the filter to (Prompt, Completion)')
  source: string
}

// ================================================= Parameters =================================================
@description('The name of the existing Cognitive Services account where the RAI policy will be created.')
@minLength(2)
@maxLength(64)
param accountName string

@description('The name of the RAI policy to create.')
@minLength(1)
@maxLength(64)
param policyName string

@description('The mode of the RAI policy.')
@allowed([
  'Default'
  'Blocking'
])
param mode string = 'Default'

@description('The base policy name to inherit from (if using Default mode).')
param basePolicyName string = ''

@description('''
Array of content filters to apply. Each filter should have the following structure:
[
  {
    name: 'Violence'
    severityThreshold: 'Low' | 'Medium' | 'High'
    blocking: true | false
    enabled: true | false
    source: 'Prompt' | 'Completion'
  }
]
''')
param contentFilters contentFilter[] = []

// ================================================= Existing Resources =================================================
@description('Reference to the existing Cognitive Services account')
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: accountName
}

// ================================================= Variables =================================================
@description('Build the properties object based on the mode')
var policyProperties = mode == 'Default'
  ? {
      mode: mode
      basePolicyName: basePolicyName
      contentFilters: contentFilters
    }
  : {
      mode: mode
      contentFilters: contentFilters
    }

// ================================================= Resources =================================================
@description('Create the RAI policy')
resource raiPolicy 'Microsoft.CognitiveServices/accounts/raiPolicies@2025-04-01-preview' = {
  parent: cognitiveServicesAccount
  name: policyName
  properties: policyProperties
}

// ================================================= Outputs =================================================
@description('The name of the created RAI policy')
output policyName string = raiPolicy.name

@description('The resource ID of the created RAI policy')
output policyResourceId string = raiPolicy.id
