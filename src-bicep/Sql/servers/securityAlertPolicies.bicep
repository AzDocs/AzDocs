/*
.SYNOPSIS
Configuring a SQL server advanced security alert policy. It enables MICROSOFT DEFENDER FOR SQL and ADVANCED THREAT PROTECTION SETTINGS.
Storage is no longer required to hold Advanced Threat Protection Alerts.
.DESCRIPTION
Creates or updates the Defender for Cloud SQL advanced security alert policy on an existing Azure SQL server.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Sql servers/securityAlertPolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/securityalertpolicies?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name of the existing SQL Server.')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('State of the advanced security alert policy.')
@allowed([
  'Enabled'
  'Disabled'
])
param securityAlertPolicyState string = 'Enabled'

type DisabledAlert =
  | 'Sql_Injection'
  | 'Sql_Injection_Vulnerability'
  | 'Access_Anomaly'
  | 'Data_Exfiltration'
  | 'Unsafe_Action'
  | 'Brute_Force'

@description('Array of disabled alert types. Allowed values include Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action, and Brute_Force.')
param disabledAlerts DisabledAlert[] = []

@description('Whether security alerts should be sent to account administrators.')
param emailAccountAdmins bool = false

@description('Array of e-mail addresses that should receive security alerts.')
param emailAddresses array = []

@description('Number of days to retain Threat Detection audit logs. Set to 0 to leave it unset.')
@minValue(0)
param retentionDays int = 0

@description('Storage account access key used when writing Threat Detection audit logs to a custom storage endpoint.')
@secure()
param storageAccountAccessKey string = ''

@description('Blob storage endpoint for Threat Detection audit logs, for example https://myaccount.blob.core.windows.net.')
param storageEndpoint string = ''

var useCustomStorageForThreatDetection = !empty(storageEndpoint) && !empty(storageAccountAccessKey)

var securityAlertPolicyProperties = union(
  {
    state: securityAlertPolicyState
  },
  length(disabledAlerts) > 0 ? {
    disabledAlerts: disabledAlerts
  } : {},
  emailAccountAdmins ? {
    emailAccountAdmins: emailAccountAdmins
  } : {},
  length(emailAddresses) > 0 ? {
    emailAddresses: emailAddresses
  } : {},
  retentionDays > 0 ? {
    retentionDays: retentionDays
  } : {},
  useCustomStorageForThreatDetection ? {
    storageAccountAccessKey: storageAccountAccessKey
    storageEndpoint: storageEndpoint
  } : {}
)

// ================================================= Existing Resources =================================================
@description('Fetch the existing SQL server to apply security alert settings to.')
resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
  name: sqlServerName
}

// ================================================= Resources =================================================
@description('Upsert the SQL server advanced security alert policy.')
resource sqlServerAdvancedSecurityAssessment 'Microsoft.Sql/servers/securityAlertPolicies@2025-01-01' = {
  parent: sqlServer
  name: 'Default'
  properties: securityAlertPolicyProperties
}

@description('Output the name of the SQL server security alert policy.')
output securityAlertPolicyName string = sqlServerAdvancedSecurityAssessment.name
@description('Output the resource ID of the SQL server security alert policy.')
output securityAlertPolicyResourceId string = sqlServerAdvancedSecurityAssessment.id
