@description('The name for this activity log alert resource')
@minLength(1)
@maxLength(260)
param activityLogAlertName string

@description('Allows you to override the scription for this activity log alert. This will default to the same value as the activity log alert name')
param activityLogAlertDescription string = activityLogAlertName

@description('The actiongroups to trigger when this alert gets activated. Please refer to the default Bicep documentation: https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/activitylogalerts?tabs=bicep')
param actionGroups array

@description('The condition the alert should match to actually get triggered.. Please refer to the default Bicep documentation: https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/activitylogalerts?tabs=bicep')
param condition object

@description('The scope this alert will apply to. This defaults to the whole subscription, but you can pass an array of resourceId\'s to apply to. Please refer to the default Bicep documentation: https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/activitylogalerts?tabs=bicep')
param scopes array = [subscription().id]

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the activityLogAlert resource')
resource activityLogAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: activityLogAlertName
  tags: tags
  location: 'Global'
  properties: {
    enabled: true
    description: activityLogAlertDescription
    scopes: scopes
    condition: condition
    actions: {
      actionGroups: actionGroups
    }
  }
}
