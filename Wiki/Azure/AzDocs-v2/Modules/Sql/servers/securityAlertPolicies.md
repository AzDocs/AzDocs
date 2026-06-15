# securityAlertPolicies

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="DisabledAlert">DisabledAlert</a>  | <pre></pre> |  |  | 

## Synopsis
Configuring a SQL server advanced security alert policy. It enables MICROSOFT DEFENDER FOR SQL and ADVANCED THREAT PROTECTION SETTINGS.<br>
Storage is no longer required to hold Advanced Threat Protection Alerts.

## Description
Creates or updates the Defender for Cloud SQL advanced security alert policy on an existing Azure SQL server.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The name of the existing SQL Server. |
| securityAlertPolicyState | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | State of the advanced security alert policy. |
| disabledAlerts | DisabledAlert[] | <input type="checkbox"> | None | <pre>[]</pre> | Array of disabled alert types. Allowed values include Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action, and Brute_Force. |
| emailAccountAdmins | bool | <input type="checkbox"> | None | <pre>false</pre> | Whether security alerts should be sent to account administrators. |
| emailAddresses | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of e-mail addresses that should receive security alerts. |
| retentionDays | int | <input type="checkbox"> | Value between 0-* | <pre>0</pre> | Number of days to retain Threat Detection audit logs. Set to 0 to leave it unset. |
| storageAccountAccessKey | string | <input type="checkbox"> | None | <pre>''</pre> | Storage account access key used when writing Threat Detection audit logs to a custom storage endpoint. |
| storageEndpoint | string | <input type="checkbox"> | None | <pre>''</pre> | Blob storage endpoint for Threat Detection audit logs, for example https://myaccount.blob.core.windows.net. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| securityAlertPolicyName | string | Output the name of the SQL server security alert policy. |
| securityAlertPolicyResourceId | string | Output the resource ID of the SQL server security alert policy. |

## Examples
<pre>
module sqlSecurityAlert 'br:contosoregistry.azurecr.io/sql/servers/securityalertpolicies.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'sqlalert')
  params: {
    sqlServerName: sqlServerName
    securityAlertPolicyState: 'Enabled'
  }
}
</pre>
<p>Enables advanced security assessment policy for an existing SQL server.</p>

## Links
- [Bicep Microsoft.Sql servers/securityAlertPolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/securityalertpolicies?pivots=deployment-language-bicep)
