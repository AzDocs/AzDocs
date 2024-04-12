@description('The resource name')
@minLength(1)
param name string

@description('The rule name as it is displayed in UI')
@minLength(1)
param displayName string

@description('	A flag that indicates whether this rule is enabled by the user')
param isRuleEnabled bool = true

@description('The rule description')
@minLength(1)
param ruleDescription string

@description('URL which displays additional info about the proactive detection rule')
@minLength(1)
param helpUrl string

@description('	A flag indicating whether the rule is enabled by default')
param IsEnabledByDefault bool = true

@description('A flag indicating whether the rule is hidden (from the UI)')
param isHiddenFromUI bool = false

@description('A flag indicating whether the rule is in preview')
param IsInPreview bool = false

@description('A flag indicating whether email notifications are supported for detections for this rule')
param SupportsEmailNotifications bool = true

@description('Parent Application Insights resource')
@minLength(1)
param applicationInsightsName string

@description('Additional email recipients for smart detection notification, separated by semicolons.')
param smartDetectionEmailRecipients string

@description('A flag that indicated whether notifications on this rule should be sent to subscription owners')
param SendEmailsToSubscriptionOwners bool = true

resource applicationInsights 'microsoft.insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource config 'Microsoft.Insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: applicationInsights
  name: name
  properties: {
    CustomEmails: [
      smartDetectionEmailRecipients
    ]
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

output id string = config.id
output ame string = config.name
