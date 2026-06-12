# securityAlertPolicies

Target Scope: resourceGroup

## Synopsis
Configuring a SQL server advanced security alert policy

## Description
Creates or updates the advanced security alert policy on an existing Azure SQL server.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The name of the existing SQL Server. |
| securityAlertPolicyState | string | <input type="checkbox"> | 'Enabled' or 'Disabled' | <pre>'Enabled'</pre> | State of the advanced security alert policy. |

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
