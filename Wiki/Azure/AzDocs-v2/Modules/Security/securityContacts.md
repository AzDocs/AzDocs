# securityContacts

Target Scope: subscription

## Synopsis
Configuring Security Contact settings for Defender for Cloud on a Subscription

## Description
Configuring Security Contact settings for Defender for Cloud on a Subscription. You need to do the deploying on a subscription level.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| alertNotificationMinimalSeverity | string | <input type="checkbox"> | `'High'` or `'Low'` or `'Medium'` | <pre>'High'</pre> | Defines the minimal alert severity which will be sent as email notifications |
| alertNotificationState | string | <input type="checkbox"> | `'Off'` or `'On'` | <pre>'On'</pre> | Defines whether to send email notifications about new security alerts |
| securityContactEmailAddress | string | <input type="checkbox" checked> | None | <pre></pre> | List of email addresses which will get notifications from Microsoft Defender for Cloud by the configurations defined in this security contact. |
| notificationsByRoleRoles | array | <input type="checkbox"> | `'AccountAdmin'` or `'Contributor'` or `'Owner'` or `'ServiceAdmin'` | <pre>['Owner']</pre> | Defines whether to send email notifications from Microsoft Defender for Cloud to persons with specific RBAC roles on the subscription. |
| notificationsByRoleState | string | <input type="checkbox"> | `'Off'` or `'On'` | <pre>'On'</pre> | Defines if email notifications will be sent about new security alerts |
| securityContactPhoneNumber | string | <input type="checkbox"> | None | <pre>''</pre> | The security contact\'s phone number |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
<pre>
module defenderSecurityContacts 'Security/securityContacts.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 39), 'defenderSecurityContacts')
  params: {
    securityContactEmailAddress: 'email@address.com'
  }
}
</pre>
<p>Configuring Security Contact settings for Defender for Cloud on a Subscription</p>

## Links
- [Bicep Security Contacts Defender for Cloud ](https://learn.microsoft.com/en-us/azure/templates/microsoft.security/securitycontacts?pivots=deployment-language-bicep)


