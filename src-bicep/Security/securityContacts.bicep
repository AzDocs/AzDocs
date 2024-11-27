/*
.SYNOPSIS
Configuring Security Contact settings for Defender for Cloud on a Subscription
.DESCRIPTION
Configuring Security Contact settings for Defender for Cloud on a Subscription. You need to do the deploying on a subscription level.
.EXAMPLE
<pre>
module defenderSecurityContacts 'Security/securityContacts.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 39), 'defenderSecurityContacts')
  params: {
    securityContactEmailAddress: 'email@address.com'
  }
}
</pre>
<p>Configuring Security Contact settings for Defender for Cloud on a Subscription</p>
.LINKS
- [Bicep Security Contacts Defender for Cloud ](https://learn.microsoft.com/en-us/azure/templates/microsoft.security/securitycontacts?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
targetScope = 'subscription'

@description('Defines the minimal alert severity which will be sent as email notifications')
@allowed([
  'High'
  'Low'
  'Medium'
])
param alertNotificationMinimalSeverity string = 'High'

@description('Defines whether to send email notifications about new security alerts')
@allowed([
  'Off'
  'On'
])
param alertNotificationState string = 'On'

@description('List of email addresses which will get notifications from Microsoft Defender for Cloud by the configurations defined in this security contact.')
param securityContactEmailAddress string

@description('Defines whether to send email notifications from Microsoft Defender for Cloud to persons with specific RBAC roles on the subscription.')
@allowed([
  'AccountAdmin'
  'Contributor'
  'Owner'
  'ServiceAdmin'
])
param notificationsByRoleRoles array = ['Owner']

@description('Defines if email notifications will be sent about new security alerts')
@allowed([
  'Off'
  'On'
])
param notificationsByRoleState string = 'On'

@description('The security contact\'s phone number')
param securityContactPhoneNumber string = ''

resource defenderForCloudSecurityContacts 'Microsoft.Security/securityContacts@2020-01-01-preview' = {
  name: 'default'
  properties: {
    alertNotifications: {
      minimalSeverity: alertNotificationMinimalSeverity
      state: alertNotificationState
    }
    emails: securityContactEmailAddress
    notificationsByRole: {
      roles: notificationsByRoleRoles
      state: notificationsByRoleState
    }
    phone: securityContactPhoneNumber
  }
}
