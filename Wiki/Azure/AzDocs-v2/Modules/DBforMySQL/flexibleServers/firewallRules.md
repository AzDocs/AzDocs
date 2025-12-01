# firewallRules

Target Scope: resourceGroup

## Synopsis
Adds or configures firewall rules for an existing Azure Database for MySQL Flexible Server.

## Description
This file declares firewall rule child resources for a MySQL flexible server. Use this module<br>
to create or update server-level firewall rules which control public access by IP ranges.<br>
The server must already exist; this module targets the `firewallRules` child resource.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| mySqlFlexibleServerName | string | <input type="checkbox" checked> | None | <pre></pre> | Server Name for the existing Azure MySQL flexible server where rules will be applied. |
| firewallRuleName | string | <input type="checkbox" checked> | None | <pre></pre> | Name of the firewall rule to create or update. |
| firewallStartIpAddress | string | <input type="checkbox" checked> | None | <pre></pre> | Starting IP address for the firewall rule. |
| firewallEndIpAddress | string | <input type="checkbox" checked> | None | <pre></pre> | Ending IP address for the firewall rule. |

## Examples
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

## Links
- https://learn.microsoft.com/azure/mysql/flexible-server/
