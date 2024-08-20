/*
.SYNOPSIS
Configuring a Proactive Detection Config.
.DESCRIPTION
Configuring a Proactive Detection Config for a smart detection rule in Application Insights.
<pre>
module proactivedetectionconfig 'br:contosoregistry.azurecr.io/insights/components/proactivedetectionconfigs:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 32), 'degradationindependencyduration')
  dependsOn: [
    applicationInsights
  ]
  params: {
    name: 'degradationindependencyduration'
    displayName: 'Degradation in dependency duration'
    ruleDescription: 'Smart Detection rules notify you of performance anomaly issues.'
    helpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
    applicationInsightsName: applicationInsights.outputs.appInsightsName
    customEmails: customEmails
  }
}
</pre>
<p>Configures a smart detection rule with the name 'Degradation in dependency duration' that is integrated in applicationInsights.</p>
.LINKS
- [Bicep Proactive Detection Configs](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2018-05-01-preview/components/proactivedetectionconfigs?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('''
The internal resource name for the proactive detection rule you want to set the config to.
''')
@allowed([
  'slowpageloadtime'
  'slowserverresponsetime'
  'longdependencyduration'
  'degradationinserverresponsetime'
  'degradationindependencyduration'
  'extension_traceseveritydetector'
  'extension_exceptionchangeextension'
  'extension_memoryleakextension'
  'extension_securityextensionspackage'
  'extension_canaryextension'
  'extension_billingdatavolumedailyspikeextension'
  'digestMailConfiguration'
  'migrationToAlertRulesCompleted'
])
param name string

@description('The rule name as it is displayed in UI')
@minLength(1)
param displayName string

@description('A flag that indicates whether this rule is enabled by the user')
param isRuleEnabled bool = true

@description('The rule description')
@minLength(1)
param ruleDescription string

@description('URL which displays additional info about the proactive detection rule')
@minLength(1)
param helpUrl string

@description('A flag indicating whether the rule is enabled by default')
param IsEnabledByDefault bool = true

@description('A flag indicating whether the rule is hidden (from the UI)')
param isHiddenFromUI bool = false

@description('A flag indicating whether the rule is in preview')
param IsInPreview bool = false

@description('A flag indicating whether email notifications are supported for detections for this rule')
param SupportsEmailNotifications bool = true

@description('Existing parent Application Insights resource')
param applicationInsightsName string

@description('Additional email recipients for smart detection notification')
param customEmails array = [ ]

@description('A flag that indicated whether notifications on this rule should be sent to subscription owners')
param SendEmailsToSubscriptionOwners bool = false

resource applicationInsights 'microsoft.insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource config 'Microsoft.Insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: applicationInsights
  name: name
  properties: {
    CustomEmails: customEmails
    Enabled: isRuleEnabled
    RuleDefinitions: {
      DisplayName: displayName
      Description: ruleDescription
      HelpUrl: helpUrl
      IsHidden: isHiddenFromUI
      IsEnabledByDefault: IsEnabledByDefault
      IsInPreview: IsInPreview
      Name: name
      SupportsEmailNotifications: SupportsEmailNotifications
    }
    SendEmailsToSubscriptionOwners: SendEmailsToSubscriptionOwners
  }
}

@description('The Resource ID of the upserted proactive detection config.')
output proActiveDetectionConfigId string = config.id
@description('The name of the upserted proactive detection config.')
output proActiveDetectionConfigName string = config.name
