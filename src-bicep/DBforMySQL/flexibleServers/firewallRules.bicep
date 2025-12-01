/*
.SYNOPSIS
Adds or configures firewall rules for an existing Azure Database for MySQL Flexible Server.
.DESCRIPTION
This file declares firewall rule child resources for a MySQL flexible server. Use this module
to create or update server-level firewall rules which control public access by IP ranges.
The server must already exist; this module targets the `firewallRules` child resource.
.PARAMETER mySqlFlexibleServerName
Name of the existing MySQL flexible server where rules will be applied.
.PARAMETER firewallRules
An array of firewall rule objects to create. Each object should include `name`, `startIpAddress`, and `endIpAddress`.
.EXAMPLE
<pre>
module mysqlFirewall 'br:contosoregistry.azurecr.io/dbformysql/flexibleservers/firewallrules:latest' = {
  name: '${deployment().name}-mysql-fw'
  params: {
    mySqlFlexibleServerName: 'my-mysql-server'
    firewallRules: [
      {
        name: 'ClientIPAddress'
        startIpAddress: '203.0.113.5'
        endIpAddress: '203.0.113.5'
      }
    ]
  }
}
</pre>
<p>Creates a firewall rule allowing access from the specified client IP address.</p>
.EXAMPLE
<pre>
module mysqlFirewall 'br:contosoregistry.azurecr.io/dbformysql/flexibleservers/firewallrules:latest' = {
  name: '${deployment().name}-mysql-fw'
  params: {
    mySqlFlexibleServerName: 'my-mysql-server'
    firewallRules: [
      {
        name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
        startIpAddress: '0.0.0.0'
        endIpAddress: '0.0.0.0'
      }
    ]
  }
}
</pre>
<p>Creates a firewall rule allowing access from all Azure services and resources within Azure IPs.</p>
.LINKS
- https://learn.microsoft.com/azure/mysql/flexible-server/
.NOTES
- Setting start and end IP both to `0.0.0.0` allows Azure services to access the server.
*/
@description('Server Name for the existing Azure MySQL flexible server where rules will be applied.')
param mySqlFlexibleServerName string

@description('Name of the firewall rule to create or update.')
param firewallRuleName string

@description('Starting IP address for the firewall rule.')
param firewallStartIpAddress string

@description('Ending IP address for the firewall rule.')
param firewallEndIpAddress string


resource mySqlFlexibleServer 'Microsoft.DBforMySQL/flexibleServers@2024-12-30' existing = {
  name: mySqlFlexibleServerName
}

resource firewallRulesResource 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2024-12-30' = {
  parent: mySqlFlexibleServer
  name: firewallRuleName
  properties: {
    startIpAddress: firewallStartIpAddress
    endIpAddress: firewallEndIpAddress
  }
}
