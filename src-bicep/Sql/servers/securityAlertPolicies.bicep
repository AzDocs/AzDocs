/*
.SYNOPSIS
Configuring a SQL server advanced security alert policy.
.DESCRIPTION
Creates or updates the advanced security alert policy on an existing Azure SQL server.
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

// ================================================= Existing Resources =================================================
@description('Fetch the existing SQL server to apply security alert settings to.')
resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
  name: sqlServerName
}

// ================================================= Resources =================================================
@description('Upsert the SQL server advanced security alert policy.')
resource sqlServerAdvancedSecurityAssessment 'Microsoft.Sql/servers/securityAlertPolicies@2025-01-01' = {
  parent: sqlServer
  name: 'advancedSecurityAssessment'
  properties: {
    state: securityAlertPolicyState
  }
}

@description('Output the name of the SQL server security alert policy.')
output securityAlertPolicyName string = sqlServerAdvancedSecurityAssessment.name
@description('Output the resource ID of the SQL server security alert policy.')
output securityAlertPolicyResourceId string = sqlServerAdvancedSecurityAssessment.id
